#include <stdio.h>
#include <stdint.h>

//The S-Boxes
const uint8_t S_Boxes[10][16] = {
    {14, 9, 15, 0, 13, 4, 10, 11, 1, 2, 8, 3, 7, 6, 12, 5},
    {4, 11, 14, 9, 15, 13, 0, 10, 7, 12, 5, 6, 2, 8, 1, 3},
    {1, 14, 7, 12, 15, 13, 0, 6, 11, 5, 9, 3, 2, 4, 8, 10},
    {7, 6, 8, 11, 0, 15, 3, 14, 9, 10, 12, 13, 5, 2, 4, 1},
    {14, 5, 15, 0, 7, 2, 12, 13, 1, 8, 4, 9, 11, 10, 6, 3},
    {2, 13, 11, 12, 15, 14, 0, 9, 7, 10, 6, 3, 1, 8, 4, 5},
    {11, 9, 4, 14, 0, 15, 10, 13, 6, 12, 5, 7, 3, 8, 1, 2},
    {13, 10, 15, 0, 14, 4, 9, 11, 2, 1, 8, 3, 7, 5, 12, 6},
    {8, 7, 14, 5, 15, 13, 0, 6, 11, 12, 9, 10, 2, 4, 1, 3},
    {11, 5, 15, 0, 7, 2, 9, 13, 4, 8, 1, 12, 14, 10, 3, 6}
};

uint32_t round_function_F(uint32_t X, uint32_t Ki) {
    uint32_t xor_out = X ^ Ki;
    uint32_t s_out = 0;

    //S-function
    for(int i = 0; i < 8; i++){
        uint8_t index = (xor_out >> (i*4)) & 0xF;
        s_out |= (uint32_t)S_Boxes[i][index] << (i*4);
    }

    //P-function
    //Split the s function output into 8 4bit parts
    uint8_t z[8], u[8];
    for (int i = 0; i < 8; i++){
        z[i] = (s_out >> (i * 4)) & 0xF;
    }
    //Connect as shown
    u[7] = z[6]; u[6] = z[4]; u[5] = z[7]; u[4] = z[5];
    u[3] = z[2]; u[2] = z[0]; u[1] = z[3]; u[0] = z[1];
    //Concantinate in final output
    uint32_t f_out = 0;
    for (int i = 0; i < 8; i++){
        f_out |= (uint32_t)u[i] << (i * 4);
    }

    return f_out;

}

void key_schedule(uint8_t *master_key, uint32_t *round_keys) {
    uint64_t k_high = 0;
    uint16_t k_low = 0;
    //We split the master key in to one 64bit and one 16 bit
    for (int i = 0; i < 8; i++) k_high = (k_high << 8) | master_key[i];
    for (int i = 8; i < 10; i++) k_low = (k_low << 8) | master_key[i];

    for (int i = 1; i <= 32; i++) {
        //We save all round keys for the decryption
        round_keys[i-1] = (uint32_t)(k_high >> 32);

        if (i < 32) {
            //Cyclical Rotate 29 bit
            uint64_t next_h = (k_high << 29) | ((uint64_t)k_low << 13) | (k_high >> 51);
            uint16_t next_l = (uint16_t)(k_high >> 35);
            k_high = next_h;
            k_low = next_l;

            //Apply S-boxes
            uint8_t k79_76 = (k_high >> 60) & 0xF;
            uint8_t k75_72 = (k_high >> 56) & 0xF;

            k_high &= 0x00FFFFFFFFFFFFFFU;
            k_high |= (uint64_t)S_Boxes[9][k79_76] << 60;
            k_high |= (uint64_t)S_Boxes[8][k75_72] << 56;

            //Xor and apply mask in the correct spot
            uint8_t k50_46 = (k_high >> 30) & 0x1F;
            k50_46 ^= (uint8_t)i;
            k_high &= ~(0x1FULL << 30);
            k_high |= (uint64_t)k50_46 << 30;
        }
    }
}

//Encryption
void lblock_encrypt(uint64_t plaintext, uint8_t *key_bytes, uint64_t *ciphertext, uint32_t round_keys[32]) {
    key_schedule(key_bytes, round_keys);
    //We split the plain text
    uint32_t X1 = (uint32_t)(plaintext >> 32);
    uint32_t X0 = (uint32_t)(plaintext & 0xFFFFFFFF);

    printf("Encryption:-------------------------------------------\n");
    //We go through 31 rounds of the algorithm and swap the outputs
    for (int i = 1; i <= 31; i++) {
        uint32_t next_X = round_function_F(X1, round_keys[i-1]) ^ ((X0 << 8) | (X0 >> 24)); // [cite: 108]
        X0 = X1;
        X1 = next_X;
        printf("Round %02d Result: %08x%08x with SubKey %08x\n", i, X1, X0, round_keys[i]);
    }

    //For the final round we dont swapthe outputs
    uint32_t X33 = round_function_F(X1, round_keys[31]) ^ ((X0 << 8) | (X0 >> 24));
    uint32_t X32 = X1;
    printf("Final Round Result: %08x%08x\n", X32, X33);
    *ciphertext = ((uint64_t)X32 << 32) | X33;
}

//Decryption
void lblock_decrypt(uint64_t *decrypted_plaintext, uint32_t round_keys[32], uint64_t ciphertext) {
    //We split the ciphertext in 2
    uint32_t X_next_1 = (uint32_t)(ciphertext >> 32);
    uint32_t X_next_2 = (uint32_t)(ciphertext & 0xFFFFFFFF);
    printf("Decryption:-------------------------------------------\n");
    //We do 32 rounds of the decryption algorithm
    for (int j = 31; j >= 0; j--) {
        uint32_t temp = round_function_F(X_next_1, round_keys[j]) ^ X_next_2;

        //Cyclical shift]
        uint32_t Xj = (temp >> 8) | (temp << 24);

        //We change the outputs for the next inputs
        X_next_2 = X_next_1;
        X_next_1 = Xj;
        printf("Round %02d Result: %08x%08x with SubKey %08x\n", 32 - j, X_next_1, X_next_2, round_keys[j]);
    }

    //Final decryption output
    printf("Final Round Result: %08x%08x\n", X_next_2, X_next_1);
    *decrypted_plaintext = ((uint64_t)X_next_2 << 32) | X_next_1;
}


int main() {

    uint64_t pt = 0x0000000000000000ULL;
    uint8_t key[10] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    uint32_t round_keys[32];
    uint64_t ct;
    uint64_t dec_pt;
    lblock_encrypt(pt, key, &ct, round_keys);
    lblock_decrypt(&dec_pt, round_keys, ct);

    printf("Plaintext:  %016llx\n", pt);
    printf("Master Key: ");
    for (int i = 0; i < 10; i++) {
        printf("%02x", key[i]);
    }
    printf("\n");
    printf("Ciphertext: %016llx\n", ct);
    printf("Decrypted Plaintext: %016llx\n", dec_pt);

    return 0;
}
