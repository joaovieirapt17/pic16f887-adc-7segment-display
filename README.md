# pic16f887-adc-7segment-display


## Project description
Write a program in Assembly code for the PIC16F887, whose ultimate goal is to read values from the
exterior of the microcontroller and display the values in a set of 7-segment displays. The program must allow the
microcontroller to read the analog value produced by an analog sensor. To simulate the sensor, a voltage divider
formed by a potentiometer will be used. The program must comply with the following requirements:

• The analog value must be read through of the analog-to-digital converter in the PIC and placed in a variable
in memory

• Reading must be triggered by the external interrupt, in the interrupt service routine, the program must distinguish the source of the interrupts, and only start the acquisition if the external interrupt line is activated the result of the ADC must be converted to BCD, such that the result of the conversion is the analog value
the AD converter’s input in decimal with one decimal place (e.g. if the analog value at the input of the
converter is 2.4 V, the result of the conversion must be 0100 0010).

• The conversion must be implemented by a look-up table in program memory.

• If the conversion result is 2.5V, the display should show the last 2 digits of the student number the main program, running continuously, must show the BCD value of the last reading in the set of two 7-segment displays.

The 7-segment displays to be used are those available in the Digital Lab IDL-Electronic lab existing 800. These 7-
segment displays are controlled by a common data bus and activation lines for each display, as shown in the figure.

For a 2 digit number to be shown, the digits must be shown alternately in each display, putting alternately each value
in the data bus and activating the correct display in each moment. The decimal point of the first display should always
be enabled.
The display may be controlled by Port C, leaving Port A free for reading the analog value through the ADC and Port
B port free for the input of the external interrupt.
