# MIPS Tone Generation Program

## Overview
This MIPS assembly program generates a tone (waveform) based on user input and writes the generated data to an output file. The user is prompted for the following parameters:
- **Output File Name**
- **Tone Frequency**
- **Sample Frequency**
- **Tone Duration (in seconds)**

The program calculates the necessary parameters, generates the waveform, and writes the data to a specified output file.

## Features
- Prompts the user for the output file name, tone frequency, sample frequency, and tone duration.
- Removes the newline character from the file path input to ensure proper file handling.
- Generates a square waveform based on the input tone frequency and sample rate.
- The program divides the tone frequency by the sample rate to generate a waveform with appropriate timing.
- Supports writing waveform data to an output file in 2-byte increments (16-bit samples).
- Includes error handling to display an error message if something goes wrong during file processing.

## Program Flow

1. **User Input**:
   - The program prompts the user for the **output file name**, **tone frequency**, **sample frequency**, and **tone duration** (in seconds).
   - The user inputs the tone frequency, sample frequency, and duration are used to calculate the total number of samples and the tone generation process.

2. **Waveform Generation**:
   - Using the sample frequency and tone frequency, the program calculates the necessary number of samples to generate the tone.
   - The waveform generated is a **square wave** alternating between two values (`0x7FFF` for high and `0x8000` for low).
   - The waveform is stored in a buffer and written to the output file.

3. **File Writing**:
   - The waveform is written to the output file in chunks of 8192 bytes.
   - The file is opened with permissions `rw-rw-r--` (577 in octal), allowing read/write access for the owner and group.

4. **Error Handling**:
   - If there’s an issue with writing to the file or processing data, an error message is displayed: `Something went wrong`.

5. **Program Exit**:
   - Once the waveform is written to the file, the program closes the file and exits.

## Instructions

1. **Assembling and Running the Program**:
   - The program is written in **MIPS assembly** and designed to be run on a MIPS simulator or processor that supports system calls (`syscall`).
   - Use a MIPS simulator (e.g., SPIM or MARS) to assemble and run the code.
   
2. **File Generation**:
   - When prompted, provide the name of the output file (e.g., `tone.wav`).
   - Input the **tone frequency** (in Hz), **sample frequency** (in Hz), and **tone duration** (in seconds).
   - The program will calculate the required number of samples and generate a square wave waveform in the specified output file.

## Code Explanation

- **User Input**:
  - The program uses syscall `4` to display prompts for user input and syscall `8` to read the input (file path, frequencies, and duration).
  - It uses `li` and `la` to load immediate values and addresses to be passed to system calls.

- **Waveform Generation**:
  - A loop (`GenerateWave`) generates samples for the square wave based on the calculated tone frequency and sample rate.
  - The program alternates between two 16-bit values: `0x7FFF` (high) and `0x8000` (low), which are written to the buffer.
  - The buffer is written to the file in chunks using syscall `15`.

- **File Handling**:
  - The program uses syscall `13` to open the file and syscall `15` to write data to the file. It handles errors by printing an error message and exiting.
  
- **Memory Management**:
  - The program uses several buffers (`path`, `header`, `buffer`) for storing user input, file header information, and waveform data respectively.

## Error Handling
If the program encounters an error (such as failure to open the file), it will display the following error message:
```
Something went wrong:
```
The program will then exit.

## Example Input and Output

### Example 1: Generating a Tone

```
Enter output file name: tone.wav
Enter tone frequency: 1000
Enter sample frequency: 8000
Enter length of tone (in seconds): 2
```

- This will generate a square wave with a tone frequency of 1000 Hz, a sample frequency of 8000 Hz, and a duration of 2 seconds.
- The program writes the generated data to `tone.wav`.

### Example 2: Handling an Error
If an error occurs while writing to the file, the program will display the error message and exit:
```
Something went wrong:
```

## System Requirements
- MIPS simulator (e.g., SPIM, MARS) or MIPS hardware
- Assembly support for MIPS system calls
