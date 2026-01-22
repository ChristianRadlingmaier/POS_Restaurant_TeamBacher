package at.htlle.Punkteapp.dtos;

public record AuthRes(String token, Long userId, Boolean role, Integer points, String firstname, String lastname, String email) {}