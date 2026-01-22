package at.htlle.Punkteapp.dtos;

import java.time.LocalDateTime;

public record HistoryItemDTO(String type, String title, Integer points, LocalDateTime date) {}