// uart_tx.v
// Модуль передавача UART
module uart_tx(
    input wire clk,         // Системний тактовий сигнал
    input wire reset,       // Скидання
    input wire tx_start,    // Сигнал початку передачі байту
    input wire [7:0] tx_data, // Передаваний байт даних
    input wire baud_tick,   // Тактовий імпульс від baud генератора
    output reg tx,          // Вихідний сигнал UART
    output reg tx_busy      // Флаг, що інформує про активну передачу
);

    reg [3:0] bit_index;    // Лічильник бітів
    reg [9:0] shift_reg;    // Зсувний регістр: start + 8 data + stop

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx <= 1'b1; // Idle стан UART — лог.1
            tx_busy <= 0;
            bit_index <= 0;
            shift_reg <= 10'b1111111111;
        end else if (baud_tick) begin
            if (tx_busy) begin
                tx <= shift_reg[0];       // Відправка поточного біта
                shift_reg <= shift_reg >> 1; // Зсув регістру
                bit_index <= bit_index + 1;
                if (bit_index == 9) begin
                    tx_busy <= 0;         // Завершення передачі
                    bit_index <= 0;
                end
            end else if (tx_start) begin
                // Формуємо пакет: start(0) + data[7:0] + stop(1)
                shift_reg <= {1'b1, tx_data, 1'b0};
                tx_busy <= 1;
                bit_index <= 0;
            end
        end
    end
endmodule
