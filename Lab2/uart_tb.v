`timescale 1ns/1ps
module uart_tb;

    // --- Тестові сигнали ---
    reg clk;           // Тактовий сигнал 50 MHz
    reg reset;         // Скидання системи
    reg tx_start;      // Сигнал запуску передачі
    reg [7:0] tx_data; // Дані для передачі
    wire tx;           // Лінія передачі UART
    wire rx;           // Лінія прийому UART
    wire tx_busy;      // Ознака, що передавач зайнятий
    wire baud_tick;    // Імпульси для UART

    wire [7:0] rx_data;  // Прийняті дані
    wire rx_ready;       // Ознака завершення прийому

    // --- Масив тестових байт ---
    reg [7:0] test_bytes [0:4];
    integer i;  // лічильник циклу

    // --- Генератор baud частоти ---
    baud_gen #(
        .CLK_FREQ(50000000),   // Частота системного такту
        .BAUD_RATE(9600)       // Швидкість UART
    ) baud_inst (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    // --- Передавач UART ---
    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .baud_tick(baud_tick),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // --- Приймач UART ---
    uart_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .baud_tick(baud_tick),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    // --- З’єднання TX → RX для симуляції ---
    assign rx = tx;

    // --- Генерація тактового сигналу 50 MHz ---
    initial clk = 0;
    always #10 clk = ~clk; // Період 20 нс = 50 MHz

    // --- Генерація файлу осцилограми ---
    initial begin
        $dumpfile("uart_tb.vcd"); // Файл для GTKWave
        $dumpvars(0, uart_tb);    // Запис усіх сигналів
    end

// --- Основний тестовий процес ---
initial begin
    // Тестові байти
    test_bytes[0] = 8'h55;
    test_bytes[1] = 8'hA3;
    test_bytes[2] = 8'h7E;
    test_bytes[3] = 8'hC1;
    test_bytes[4] = 8'h3C;

    reset = 1;
    tx_start = 0;
    #100;
    reset = 0;

    for (i = 0; i < 5; i = i + 1) begin
        tx_data = test_bytes[i];
        #50;
        tx_start = 1;
        #20;
        tx_start = 0;

        // Чекаємо, поки RX прийме байт
        wait(rx_ready == 1);

        // Перевірка прийнятого байту
        if (rx_data == test_bytes[i])
            $display("TEST PASSED: RX received %02h (expected %02h)", rx_data, test_bytes[i]);
        else
            $display("TEST FAILED: RX received %02h (expected %02h)", rx_data, test_bytes[i]);

        // Чекаємо, поки rx_ready скинеться
        wait(rx_ready == 0);

        // Додатковий час для стабілізації (≈ один байт)
        repeat(20) @(posedge baud_tick);
    end

    #1000;
    $finish;
end


endmodule