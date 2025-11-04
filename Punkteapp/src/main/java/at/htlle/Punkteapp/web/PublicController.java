package at.htlle.Punkteapp.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PublicController {
    @GetMapping("/")
    public String root() { return "PunkteApp API is up ✅"; }
}