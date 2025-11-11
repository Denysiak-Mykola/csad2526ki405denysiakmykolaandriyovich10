`timescale 1ns/1ps
module baud_gen #(
    parameter CLK_FREQ = 50000000,   // частота системного такту (50 МГц)
    parameter BAUD_RATE = 9600       // швидкість UART у бодах
)(
    input clk,                       // системний такт
    input reset,                     // сигнал скидання
    output reg baud_tick             // вихідний імпульс "baud" (1 імпульс = 1 біт)
);
    // Коефіцієнт ділення частоти
    localparam integer DIV = CLK_FREQ / BAUD_RATE;
    integer counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            baud_tick <= 0;
        end else begin
            // Генерація короткого імпульсу раз на DIV тактів
            if (counter >= DIV - 1) begin
                counter <= 0;
                baud_tick <= 1;
            end else begin
                counter <= counter + 1;
                baud_tick <= 0;
            end
        end
    end
endmodule
