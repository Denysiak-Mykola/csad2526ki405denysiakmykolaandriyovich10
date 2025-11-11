// baud_gen.v
// Модуль дільника частоти для формування тактової частоти UART (baud rate generator)
module baud_gen #(
    parameter CLK_FREQ = 50000000,  // Частота системного годинника (50 MHz)
    parameter BAUD_RATE = 9600      // Необхідна швидкість передачі
)(
    input wire clk,      // Вхідний системний тактовий сигнал
    input wire reset,    // Сигнал скидання
    output reg baud_tick // Вихідний тактовий імпульс для UART
);

    // Обчислюємо значення лічильника для генерації baud tick
    localparam integer DIVIDER = CLK_FREQ / BAUD_RATE;
    reg [31:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            baud_tick <= 0;
        end else begin
            if (counter == DIVIDER/2) begin
                baud_tick <= 1;
                counter <= counter + 1;
            end else if (counter >= DIVIDER) begin
                counter <= 0;
                baud_tick <= 0;
            end else begin
                counter <= counter + 1;
                baud_tick <= 0;
            end
        end
    end
endmodule
