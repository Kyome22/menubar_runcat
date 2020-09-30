//
//  CPU.swift
//  Menubar RunCat
//
//  Created by Takuto Nakamura on 2019/08/06.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Darwin

public class CPU {
    
    private let loadInfoCount: mach_msg_type_number_t!
    private var loadPrevious = host_cpu_load_info()
    
    init() {
        loadInfoCount = UInt32(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
    }
    
    private func hostCPULoadInfo() -> host_cpu_load_info {
        var size: mach_msg_type_number_t = loadInfoCount
        let hostInfo = host_cpu_load_info_t.allocate(capacity: 1)
        
        let _ = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) { (pointer) -> kern_return_t in
            return host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, pointer, &size)
        }
        // kern_return_t == KERN_SUCCESS
        let data = hostInfo.move()
        hostInfo.deallocate()
        
        return data
    }
    
    public func usageCPU() -> (value: Double, description: String) {
        let load = hostCPULoadInfo()
        let userDiff = Double(load.cpu_ticks.0 - loadPrevious.cpu_ticks.0)
        let sysDiff  = Double(load.cpu_ticks.1 - loadPrevious.cpu_ticks.1)
        let idleDiff = Double(load.cpu_ticks.2 - loadPrevious.cpu_ticks.2)
        let niceDiff = Double(load.cpu_ticks.3 - loadPrevious.cpu_ticks.3)
        loadPrevious = load
        
        let totalTicks = sysDiff + userDiff + idleDiff + niceDiff
        let sys  = 100.0 * sysDiff / totalTicks
        let user = 100.0 * userDiff / totalTicks
        
        let value: Double = round((sys + user) * 10.0) / 10.0
        let description: String = (value >= 100.0) ? "100↑%" : ((value < 10.0 ? " " : "") + String(value)) + "% "
        
        return (value, description)
    }
    
}
