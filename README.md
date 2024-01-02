# Programmable Interrupt Controller (PIC) - Verilog Implementation
The Computer Architecture Project centers on the design and realization of a Programmable Interrupt Controller (PIC) using Verilog hardware description language. This PIC, based on the 8259 architecture, serves as a pivotal element within computer systems, responsible for orchestrating and prioritizing interrupt requests, enabling efficient communication between peripherals and the CPU.

# Project Overview
The primary objective of this project is to meticulously emulate the behavior and features of the classic 8259 PIC while incorporating advanced functionalities to enhance its capabilities. The key features and objectives include:

# Key Features
8259 Compatibility: The Verilog implementation closely mirrors the behavior and functionalities of the 8259 PIC, ensuring seamless compatibility with existing systems and software.

Programmability: Users can configure interrupt priorities and modes using Command Words (ICWs) and Operation Command Words (OCWs), tailoring the PIC to specific system requirements.

Cascade Mode: Implementation of cascade mode allows interconnection of multiple PICs, expanding the available interrupt lines and enhancing scalability.

Interrupt Handling: Efficient handling of interrupt requests, encompassing prioritization and acknowledgment mechanisms, to guarantee a prompt and accurate response to diverse events.

Interrupt Masking: Capability to mask/unmask individual interrupt lines provides control over enabled interrupts, enhancing system flexibility.

Edge/Level Triggering: Support for both edge-triggered and level-triggered interrupt modes accommodates different peripheral types.

Fully Nested Mode: Implementation of Fully Nested Mode enables automatic CPU priority adjustment based on the highest priority interrupt being serviced.

Automatic Rotation: Priority handling mechanism supports automatic rotation, even when lower-priority interrupts are being serviced.

EOI (End of Interrupt): Implementation of EOI functionality enables the PIC to signal the CPU upon completion of interrupt processing.

AEOI (Automatic End of Interrupt): Implementation of AEOI functionality automates signaling the CPU upon interrupt processing completion.

8259A Status Reading: Capability to read the status of the 8259A PIC enhances system monitoring and control.

Simulation and Testing: Development of a comprehensive testbench facilitates simulation and validation of the Verilog-based 8259 PIC. Extensive testing covers various interrupt scenarios and ensures seamless interaction with other system components.

Documentation: Thorough documentation detailing design specifications, module functionalities, and usage guidelines facilitates comprehension and serves as a resource for future development.

# Conclusion
The Project aims to deliver a robust and versatile Verilog-based Programmable Interrupt Controller, enriching computer systems with advanced interrupt handling capabilities while maintaining compatibility with established architectures.

For detailed information and technical insights, refer to the accompanying documentation. Feel free to explore and leverage this PIC implementation for your computing solutions.
