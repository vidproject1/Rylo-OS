# ADR-002: QEMU as Testing Environment

## Status
Accepted

## Context
Rylo OS needs a reliable, safe, and feature-rich testing environment for development. The options considered include:
- Real hardware testing (risky, slow iteration)
- VirtualBox (limited debugging features)
- VMware (commercial, limited customization)
- QEMU (open source, extensive debugging support)
- Bochs (slower, less maintained)

For an educational OS development project spanning multiple years, the testing environment must support:
- Safe experimentation without hardware risk
- Debugging capabilities for low-level development
- Fast iteration cycles
- x86-64 architecture emulation
- UEFI/BIOS boot compatibility
- Educational use and learning

## Decision
Use QEMU as the primary testing and emulation environment for Rylo OS development.

**Specific QEMU Configuration:**
- Target architecture: x86_64 (qemu-system-x86_64)
- Boot methods: Both UEFI and BIOS support
- Debugging: GDB integration enabled
- Disk: IDE/SATA emulation for storage testing
- Memory: Configurable RAM sizes for testing
- Network: User-mode networking for future development

## Consequences

### Positive
- **Safe Development**: No risk to physical hardware
- **Excellent Debugging**: GDB integration, monitor console, state inspection
- **Fast Iteration**: Quick boot cycles, easy automation
- **Educational Value**: Students can easily replicate environment
- **Flexibility**: Multiple configurations, snapshots, and testing scenarios
- **Cost**: Free and open source
- **Documentation**: Extensive community knowledge and tutorials

### Negative
- **Performance**: Emulation overhead vs native hardware
- **Hardware Specifics**: May not catch all real-hardware edge cases
- **Learning Curve**: QEMU command-line options and configuration
- **Windows Integration**: Additional setup required on Windows host

### Risks & Mitigation
- **Risk**: Emulation differences from real hardware
  - **Mitigation**: Document QEMU-specific behaviors, plan eventual real hardware testing
- **Risk**: Complex QEMU configuration
  - **Mitigation**: Create standardized scripts and documentation
- **Risk**: Debugging complexity
  - **Mitigation**: Establish debugging workflows and document procedures

## Implementation Notes

### QEMU Installation on Windows
- Install QEMU for Windows
- Configure PATH environment variable
- Set up GDB for remote debugging
- Create boot scripts for common scenarios

### Standard Testing Configuration
```bash
qemu-system-x86_64 \
    -m 128M \
    -drive file=rylo.img,format=raw \
    -serial stdio \
    -monitor telnet:localhost:55555,server,nowait \
    -s -S  # GDB debugging support
```

### Development Workflow
1. Build OS image
2. Launch QEMU with debugging
3. Connect GDB for source-level debugging
4. Test functionality
5. Document results

### Future Considerations
- Network testing with QEMU network backends
- Multi-core testing with SMP support
- Device driver testing with specific hardware emulation
- Performance profiling with QEMU timing features

---
Date: 2025-08-06  
Author: Claude (AI Assistant)  
Review: Accepted by project lead  
Related: ADR-001 (documentation system), Phase 1 bootloader development
