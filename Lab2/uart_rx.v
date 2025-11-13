module uart_rx (
    input  wire clk,         // Тактовий сигнал
    input  wire reset,       // Скидання
    input  wire rx,          // Лінія прийому UART
    input  wire baud_tick,   // Імпульси тактування UART
    output reg [7:0] rx_data, // Прийняті дані
    output reg rx_ready      // Ознака завершення прийому
);

    // Внутрішні сигнали
    reg [3:0] bit_count;     // Лічильник бітів
    reg [7:0] shift_reg;     // Буфер прийнятих бітів
    reg receiving;           // Стан прийому
    reg [1:0] state;         // FSM: 0 — очікування, 1 — прийом, 2 — стоп-біт


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_count <= 0;
            shift_reg <= 0;
            receiving <= 0;
            rx_data   <= 0;
            rx_ready  <= 0;
            state     <= 0;
        end else if (baud_tick) begin
            case (state)

                // 0. Очікування старт-біту (rx_line == 0)
                0: begin
                    rx_ready <= 0;
                    if (rx == 0) begin
                        state <= 1;
                        bit_count <= 0;
                        receiving <= 1;
                    end
                end

                // 1. Прийом 8 біт даних (LSB першим)
                1: begin
                    shift_reg <= {rx, shift_reg[7:1]};
                    bit_count <= bit_count + 1;

                    if (bit_count == 7) begin
                        state <= 2; // Після 8 біт — стоп-біт
                    end
                end

                // 2. Очікування стоп-біту (rx_line == 1)
                2: begin
                    if (rx == 1) begin
                        rx_data <= shift_reg;
                        rx_ready <= 1;
                        receiving <= 0;
                        state <= 0; // Готові приймати наступний байт
                    end
                end
            endcase
        end
    end
endmodule
