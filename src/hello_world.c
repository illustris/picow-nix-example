/* #include "pico/stdlib.h" */

/* int main() { */
/* #ifndef PICO_DEFAULT_LED_PIN */
/* #warning blink example requires a board with a regular LED */
/* #else */
/* 	const uint LED_PIN = PICO_DEFAULT_LED_PIN; */
/* 	gpio_init(LED_PIN); */
/* 	gpio_set_dir(LED_PIN, GPIO_OUT); */
/* 	while (true) { */
/* 		gpio_put(LED_PIN, 1); */
/* 		sleep_ms(250); */
/* 		gpio_put(LED_PIN, 0); */
/* 		sleep_ms(250); */
/* 	} */
/* #endif */
/* } */
#include "pico/stdlib.h"
#include "pico/cyw43_arch.h"

int main() {
	stdio_init_all();
	if (cyw43_arch_init()) {
		printf("Wi-Fi init failed");
		return -1;
	}
	while (true) {
		cyw43_arch_gpio_put(CYW43_WL_GPIO_LED_PIN, 1);
		sleep_ms(250);
		cyw43_arch_gpio_put(CYW43_WL_GPIO_LED_PIN, 0);
		sleep_ms(250);
	}
}
