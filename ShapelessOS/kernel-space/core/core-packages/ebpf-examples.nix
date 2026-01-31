{ config, pkgs, ... }:
{
  # Example eBPF programs and scripts
  environment.etc."ebpf-examples/hello.bt".text = 
    #!/usr/bin/env bpftrace
    
    BEGIN
    {
      printf("Hello, eBPF!
Tracing system calls...
");
    }
    
    tracepoint:syscalls:sys_enter_execve
    {
      printf("%-8s %-16s %s
", comm, probe, str(args->filename));
    }
  ;
  
  environment.etc."ebpf-examples/tcp-trace.bt".text = 
    #!/usr/bin/env bpftrace
    
    // Trace TCP connections
    kprobe:tcp_connect
    {
      printf("%s connecting to port %d
", comm, args->sin_port);
    }
  ;
}
