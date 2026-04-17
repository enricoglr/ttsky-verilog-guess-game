
    module game (
        input logic clki_i, 
        input logic rst_i,
        input logic init_game_i,
        input logic guess_valid_i,
        input logic[3:0] guess_i, 
        input logic[3:0] secret_i, 
        output logic busy_o, 
        output logic valid_o, 
        output logic[2:0] correct_o,  
        output logic[2:0] wrong_o, //TODO: show both or just one ?
        output logic win_o
    );

    typedef enum logic[2:0] {INIT, LOAD_GAME, LOAD_ROUND, IDLE, COUNT_CORRECT, COUNT_WRONG, DONE_ROUND, DONE_GAME} state_t;
    localparam WIDTH = 4;
    localparam logic [2:0] MAX_GUESSES = 4'd5; 

    //Controll Logic register
    state_t state_p, state_n; 
    logic valid_p, valid_n;    

    //User Input Register
    logic[3:0] secret_p, secret_n; 
    logic[3:0] guess_p, guess_n; 

    //Computation register
    logic[3:0] secret_used_p, secret_used_n ; 
    logic[3:0] guess_used_p, guess_used_n; 
    logic [3:0] guess_counter_p, guess_counter_n; 
    logic [1:0] idx_p, idx_n;

    //Output register
    logic[2:0] correct_p, correct_n; 
    logic[2:0] wrong_p, wrong_n;

    always_ff @(posedge clki_i or posedge rst_i) begin

        if (rst_i)begin 
            state_p <= INIT; 
            valid_p <= 0; 
            correct_p <= 0; 
            wrong_p <= 0; 
            secret_used_p <= 0; 
            guess_used_p <= 0; 
            idx_p <= 0; 
            guess_counter_p <= 0; 
            secret_p <= 0; 
            guess_p <= 0; 
        end else begin
            state_p <= state_n; 
            valid_p <= valid_n; 
            correct_p <= correct_n; 
            wrong_p <= wrong_n; 
            secret_used_p <= secret_used_n; 
            guess_used_p <= guess_used_n; 
            idx_p <= idx_n; 
            guess_counter_p <= guess_counter_n; 
            secret_p <= secret_n; 
            guess_p <= guess_n; 

        end 

    end


    //Important Design Decision: 
    //guess valid muss high die ganze Zeit sein oder 2 clock cycle nach init_game_i gesetzt werden

    always_comb begin

        state_n = state_p;
        valid_n = 0;

        secret_n = secret_p; 
        guess_n = guess_p; 

        secret_used_n = secret_used_p;
        guess_used_n = guess_used_p;
        guess_counter_n = guess_counter_p; 
        idx_n = idx_p; 

        correct_n = correct_p;
        wrong_n = wrong_p;

        case(state_p)
        INIT: begin 

            secret_used_n = 0; 
            guess_used_n = 0;  
            guess_counter_n = 0; 
            idx_n = 0; 

            correct_n = 0; 
            wrong_n = 0; 

            if (init_game_i) begin
                state_n = LOAD_GAME; 
            end 
        end LOAD_GAME: begin
            secret_n = secret_i; 
            guess_counter_n = 0; 
            state_n = IDLE; 
        end LOAD_ROUND: begin
            correct_n = 0; 
            wrong_n = 0; 
            secret_used_n = 0; 
            guess_used_n = 0; 
            idx_n = 0; 
            guess_n = guess_i; 
            state_n = COUNT_CORRECT; 
            guess_counter_n = guess_counter_p + 1;  //WIESO ?
        
        end IDLE: begin
            if (init_game_i) begin 
                state_n = LOAD_GAME; 
            end else if (guess_valid_i) begin
                state_n = LOAD_ROUND; 
            end

        end COUNT_CORRECT: begin
            
            if (idx_p < WIDTH) begin
                if (secret_p[idx_p] == guess_p[idx_p])begin
                correct_n = correct_p + 1; 
                secret_used_n[idx_p] = 1; 
                guess_used_n[idx_p] = 1; 
                end 
                idx_n = idx_p +1; 
            end 

            if (idx_p == WIDTH -1) begin
                state_n = COUNT_WRONG; 
                idx_n = 0; 
            end 
            
        end COUNT_WRONG: begin

            if (!guess_used_p[idx_p]) begin 

                if (secret_p[0] == guess_p[idx_p] && !secret_used_p[0]) begin 
                    wrong_n = wrong_p +1; 
                    secret_used_n[0] = 1; //brauch ich nicht setzten oder ??
                end 
                else if (secret_p[1] == guess_p[idx_p] && !secret_used_p[1]) begin
                    wrong_n = wrong_p +1; 
                    secret_used_n[1] = 1; 
                end
                else if (secret_p[2] == guess_p[idx_p] && !secret_used_p[2]) begin
                    wrong_n = wrong_p +1; 
                    secret_used_n[2] = 1; 
                end 
                else if (secret_p[3] == guess_p[idx_p] && !secret_used_p[3]) begin
                    wrong_n = wrong_p +1; 
                    secret_used_n[3] = 1; 
                end 
            end 
            idx_n = idx_p +1; 
            if (idx_p == WIDTH -1)begin
                idx_n = 0; 
                state_n = DONE_ROUND; 
            end
        end DONE_ROUND: begin
            valid_n = 1; 

            if (guess_counter_p >= MAX_GUESSES) begin
                state_n = DONE_GAME; 
            end else begin
                state_n = IDLE; 
            end

        end DONE_GAME: begin    
            valid_n = 1; 
            state_n = IDLE; 

        end default: begin
            state_n = INIT; 
        end

        endcase     
    end
    
    assign busy_o = (state_p == LOAD_ROUND) || (state_p == LOAD_GAME) || (state_p == COUNT_CORRECT) || (state_p == COUNT_WRONG);
    assign valid_o = valid_p; 
    assign correct_o = correct_p; 
    assign wrong_o = wrong_p; 
    assign win_o = correct_p == WIDTH; 
    endmodule