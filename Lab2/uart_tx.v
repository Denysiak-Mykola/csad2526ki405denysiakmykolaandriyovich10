`timescale 1ns/1ps
module uart_tx(
    input clk,                // системний такт
    input reset,              // скидання
    input tx_start,           // запуск передачі байта
    input [7:0] tx_data,      // байт для передачі
    input baud_tick,          // тактовий імпульс з baud_gen
    output reg tx,            // вихідна лінія UART (TX)
    output reg tx_busy        // прапорець: передавач зайнятий
);
    reg [3:0] bit_index;      // лічильник біта (0..9)
    reg [9:0] shift_reg;      // регістр з усім кадром: старт, 8 біт, стоп

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx <= 1;                     // у стані спокою TX = 1
            tx_busy <= 0;
            shift_reg <= 10'b1111111111;
            bit_index <= 0;
        end else begin
            // Якщо не передаємо і отримано сигнал start
            if (!tx_busy && tx_start) begin
                // Формуємо кадр: {стоп-біт, дані, старт-біт}
                shift_reg <= {1'b1, tx_data, 1'b0};
                tx_busy <= 1;
                bit_index <= 0;
            end
            // Якщо передаємо і настав baud_tick — зсуваємо дані
            else if (tx_busy && baud_tick) begin
                tx <= shift_reg[0];                 // передаємо молодший біт
                shift_reg <= {1'b1, shift_reg[9:1]}; // зсув праворуч
                bit_index <= bit_index + 1;

                // Після 10 біт завершуємо передачу
                if (bit_index == 9)
                    tx_busy <= 0;
            end
        end
    end
endmodule
