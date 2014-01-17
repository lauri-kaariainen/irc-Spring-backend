package com.laurikaariainen.nettiirkki.service;

import java.util.ArrayList;
import java.util.Timer;
import java.util.TimerTask;

import javax.annotation.PostConstruct;
import javax.inject.Inject;
import javax.inject.Singleton;
import javax.json.Json;
import javax.json.JsonObject;

import org.atmosphere.cpr.Broadcaster;
import org.atmosphere.cpr.BroadcasterFactory;
import org.springframework.stereotype.Service;

import com.laurikaariainen.nettiirkki.bean.Channel;
import com.laurikaariainen.nettiirkki.controller.JSONController;
import com.laurikaariainen.nettiirkki.dao.ChannelDao;

/**
 * This class's method keeps channels updated and broadcasts channels' changes to corresponding Broadcasters.
 * @author lauri
 *
 */
@Singleton
@Service
public class ChannelUpdateAndBroadcastService {
	
	@Inject
	private ChannelDao channelDao;
	
	private boolean running = false;
	
	/**
	 *  This method keeps channels updated and broadcasts channels' changes to corresponding Broadcasters.
	 *  This is supposed to be called only once, and on software initialization.
	 */
	@PostConstruct
	public void BroadcastChangesToChannels(){
		
		
		
		if(running == true){
			System.out.println("broadcastchangestochannels was already running ********");
			return;
		}
		if(running == false)
		running = true;
		//System.out.println("went for a run! *******");
		
		
		
		//TIMER implementation
		Timer timer = new Timer();
		timer.scheduleAtFixedRate(new TimerTask() {
			  @Override
			  public void run() {
				  

				String[] CHANNELNAMES = JSONController.getCHANNELS();
				ArrayList<Channel> channels = new ArrayList<Channel>();
				ArrayList<Broadcaster> broadcasters = new ArrayList<Broadcaster>();
				
				for(int i = 0; i < CHANNELNAMES.length;i++){
					channels.add(channelDao.getChannel(CHANNELNAMES[i]));
					broadcasters.add(BroadcasterFactory.getDefault().lookup(CHANNELNAMES[i], true));
				}
				  
				  

				System.out.println("went for a run3! *******");
				JsonObject json;
				for(int i = 0;i < channels.size();i++){
					//Channel was updated
			//		if(channelDao.updateChannel(channels.get(i))){
						json = Json.createObjectBuilder().add("name",channels.get(i).getName()).
								add("text", channels.get(i).getText() ).
								add("timestamp",channels.get(i).getLastChanged().toString()).
								build();
						broadcasters.get(i).broadcast(json);
						System.out.println("broadcasting to channel '"+channels.get(i).getName()+
								"', and text '"+channels.get(i).getText()+"'"+
								"broadcaster's id: '"+broadcasters.get(i).getID()+"'");
		//			}
				}
				
				
				System.out.println("While-loop went around!");
				
			  
			  
			  }
			}, 100, 1500);
		
		
		/*
		//TODO: This is still bad form, implement the goddamn timer
		long counter = 0;
		while(true){
			System.out.println("went for a run3! *******");
			for(int i = 0;i < channels.size();i++){
				//Channel was updated
				if(channelDao.updateChannel(channels.get(i))){
					JsonObject json = Json.createObjectBuilder().add("name",channels.get(i).getName()).
							add("text", channels.get(i).getText() ).
							add("timestamp",channels.get(i).getLastChanged().toString()).
							build();
					broadcasters.get(i).broadcast(json);
				}
			}
			
			counter = counter > (2^64-3) ? 0 : counter + 1;
			System.out.println("While-loop went around:" + counter);
			try {
				Thread.sleep(1500);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			
		}
		*/
		
	}
	
	
	
}
