package com.laurikaariainen.nettiirkki.util;

import javax.inject.Inject;
import javax.servlet.ServletContextEvent;

import com.laurikaariainen.nettiirkki.service.ChannelUpdateAndBroadcastService;



public class StartupListener implements javax.servlet.ServletContextListener {
	
	@Inject
	private ChannelUpdateAndBroadcastService cuabs;
	
	public void contextInitialized(ServletContextEvent sce) {
		System.out.println("startup duty done: "+cuabs);
	}

	public void contextDestroyed(ServletContextEvent sce) {
	
	
	}
} 