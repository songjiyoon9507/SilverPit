package com.silverfitterpan.mobileweb.event.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("event")
public class EventController {

	@GetMapping("parentsDay")
	public String parentsDay() {
		return "event/parentsDay";
	}
	
	@GetMapping("firstTrial")
	public String firstTrial() {
		return "event/firstTrial";
	}
}
