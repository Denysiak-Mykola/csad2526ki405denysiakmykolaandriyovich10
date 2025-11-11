// uart_rx.v
// Модуль приймача UART
module uart_rx(
    input wire clk,          // Системний тактовий сигнал
    input wire reset,        // Скидання
    input wire rx,           // Вхідний сигнал UART
    input wire baud_tick,    // Тактовий імпульс від baud генератора
    output reg [7:0] rx_data, // Прийнятий байт
    output reg rx_ready      // Флаг готовності прийняти дані
);

    reg [3:0] bit_index;
    reg [7:0] shift_reg;
    reg receiving;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_index <= 0;
            shift_reg <= 0;
            rx_data <= 0;
            rx_ready <= 0;
            receiving <= 0;
        end else if (baud_tick) begin
            if (!receiving) begin
                if (rx == 0) begin // Виявлено старт-біт
                    receiving <= 1;
                    bit_index <= 0;
                    rx_ready <= 0;
                end
            end else begin
                shift_reg[bit_index] <= rx;
                bit_index <= bit_index + 1;
                if (bit_index == 7) begin
                    rx_data <= shift_reg;
                    rx_ready <= 1;
                    receiving <= 0;
                end
            end
        end
    end
endmodule
