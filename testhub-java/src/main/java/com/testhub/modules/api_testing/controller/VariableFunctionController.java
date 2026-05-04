package com.testhub.modules.api_testing.controller;

import com.testhub.modules.api_testing.dto.VariableFunctionDTO;
import com.testhub.modules.api_testing.service.VariableFunctionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 变量函数控制器
 * 提供变量助手功能，如随机数、时间戳等
 */
@RestController
@RequestMapping("/api/data-factory")
public class VariableFunctionController {

    @Autowired
    private VariableFunctionService variableFunctionService;

    @GetMapping("/variable_functions")
    public ResponseEntity<List<VariableFunctionDTO>> getVariableFunctions() {
        List<VariableFunctionDTO> functions = variableFunctionService.getAllVariableFunctions();
        return ResponseEntity.ok(functions);
    }
}