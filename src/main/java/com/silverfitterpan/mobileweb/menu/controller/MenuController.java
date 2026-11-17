package com.silverfitterpan.mobileweb.menu.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("menu")
public class MenuController {

	@GetMapping("move1")
	public String move1() {
		return "menu/move1";
	}
	
	@GetMapping("move2")
	public String move2() {
		return "menu/move2";
	}
	
	@GetMapping("move3")
	public String move3() {
		return "menu/move3";
	}
	
	@GetMapping("move4")
	public String move4() {
		return "menu/move4";
	}
	
	@GetMapping("allMenu")
	public String allMenu() {
		return "menu/allMenu";
	}
	
	@GetMapping("visitPT")
	public String visitPT() {
		return "menu/visitPT";
	}
	
	@GetMapping("programOrder")
	public String programOrder() {
		return "menu/programOrder";
	}
}
