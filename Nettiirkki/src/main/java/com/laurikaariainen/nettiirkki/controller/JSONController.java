package com.laurikaariainen.nettiirkki.controller;

import java.text.DateFormat;
import java.util.Date;
import java.util.Locale;

import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.laurikaariainen.nettiirkki.bean.Channel;
import com.laurikaariainen.nettiirkki.service.ChannelService;

/**
 * Handles requests for the application home page.
 */
@Controller
public class JSONController {
	
	@Inject
	private ChannelService channelService;
	
	private static final Logger logger = LoggerFactory.getLogger(JSONController.class);
	
	/**
	 * Simply selects the home view to render by returning its name.
	 */
	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String home(Locale locale, Model model) {
		logger.info("Welcome home! The client locale is {}.", locale);
		
		Date date = new Date();
		DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG, locale);
		
		String formattedDate = dateFormat.format(date);
		
		model.addAttribute("serverTime", formattedDate );
		
		return "home";
	}
	
	@RequestMapping(value ="/otaniemi", method = RequestMethod.GET)
	public String getOtaniemi(Model model){
		
		Channel channel = channelService.getChannel("#otaniemi");
		System.out.println("*"+channel.getText()+"*");
		model.addAttribute("channel", channel);
		
		return "channel";
	}
	
	@RequestMapping(value ="/punttis", method = RequestMethod.GET)
	public String getpunttis(Model model){
		
		Channel channel = channelService.getChannel("#punttis");
		System.out.println("*"+channel.getText()+"*");
		model.addAttribute("channel", channel);
		
		return "channel";
	}
	
	@RequestMapping(value ="/3pyy", method = RequestMethod.GET)
	public String get3pyy(Model model){
		
		Channel channel = channelService.getChannel("!3pyy");
		System.out.println("*"+channel.getText()+"*");
		model.addAttribute("channel", channel);
		
		return "channel";
	}
	
}
