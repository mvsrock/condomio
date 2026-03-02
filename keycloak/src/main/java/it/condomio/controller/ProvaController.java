package it.condomio.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;

@RestController
@Slf4j
@RequestMapping("/public")
public class ProvaController {
    @GetMapping("/test")
    public void testLogs(

    ) {
        log.trace("[TRACE] ");
        log.debug("[DEBUG] ");
        log.info ("[INFO ] ");
        log.warn ("[WARN ] ");
        log.error("[ERROR] ");


    }
}
