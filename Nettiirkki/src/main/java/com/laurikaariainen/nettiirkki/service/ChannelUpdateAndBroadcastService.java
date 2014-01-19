package com.laurikaariainen.nettiirkki.service;

import java.util.ArrayList;
import java.util.Timer;
import java.util.TimerTask;

import javax.annotation.PostConstruct;
import javax.inject.Inject;
import javax.inject.Singleton;
import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;

import org.atmosphere.cpr.Broadcaster;
import org.atmosphere.cpr.BroadcasterFactory;
import org.springframework.stereotype.Service;

import com.laurikaariainen.nettiirkki.bean.Channel;
import com.laurikaariainen.nettiirkki.controller.JSONController;
import com.laurikaariainen.nettiirkki.dao.ChannelDao;

/**
 * This class's method keeps channels updated and broadcasts channels' changes
 * to corresponding Broadcasters.
 * 
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
	 * This method keeps channels updated and broadcasts channels' changes to
	 * corresponding Broadcasters. This is supposed to be called only once, and
	 * on software initialization.
	 */
	@PostConstruct
	public void BroadcastChangesToChannels() {

		if (running == true) {
			System.out
					.println("broadcastchangestochannels was already running ********");
			return;
		}
		if (running == false)
			running = true;
		// System.out.println("went for a run! *******");

		String[] CHANNELNAMES = JSONController.getCHANNELS();
		ArrayList<Channel> channels = new ArrayList<Channel>();
		ArrayList<Broadcaster> broadcasters = new ArrayList<Broadcaster>();
		ArrayList<Boolean> activeChannels = new ArrayList<Boolean>();

		for (int i = 0; i < CHANNELNAMES.length; i++) {
			channels.add(channelDao.getChannel(CHANNELNAMES[i]));
			broadcasters.add(BroadcasterFactory.getDefault().lookup(
					CHANNELNAMES[i], true));
			activeChannels.add(false);
		}

		// TIMER implementation
		Timer timer = new Timer();
		timer.scheduleAtFixedRate(
				new ChannelUpdateAndBroadcastServiceTimerTask(channels,
						broadcasters,activeChannels), 100, 1500);
	}

	// ////////////////////////////////////////////////
	
	/**
	 * this is a classy(?) way to circumvent the fact that inside normal TimerTask
	 * is not possible to carry variables
	 * @author lauri
	 *
	 */
	private class ChannelUpdateAndBroadcastServiceTimerTask extends TimerTask {
		ArrayList<Channel> channels = new ArrayList<Channel>();
		ArrayList<Broadcaster> broadcasters = new ArrayList<Broadcaster>();
		ArrayList<Boolean> activeChannels = new ArrayList<Boolean>();
		public ChannelUpdateAndBroadcastServiceTimerTask(
				ArrayList<Channel> channels, ArrayList<Broadcaster> broadcasters, ArrayList<Boolean> activeChannels) {
			this.channels = channels;
			this.broadcasters = broadcasters;
			this.activeChannels = activeChannels;
		}

		@Override
		public void run() {
			// System.out.println("went for a run3! *******");
			JsonObject json;
			JsonObjectBuilder jsonBuild;
			for (int i = 0; i < channels.size(); i++) {
				// Channel was updated
				if (channelDao.updateChannel(this.channels.get(i))) {
					this.activeChannels.set(i,true);
					jsonBuild = Json
							.createObjectBuilder()
							.add("name", this.channels.get(i).getName())
							.add("text", this.channels.get(i).getText())
							.add("timestamp", this.channels.get(i).getLastChanged().toString());
									
							
					json = jsonBuild.build();
					
					broadcasters.get(i).broadcast(json);

				/*	System.out.println("broadcasting to channel '"
							+ channels.get(i).getName() + "', and text '"
							+ channels.get(i).getText() + "'"
							+ "broadcaster's id: '"
							+ broadcasters.get(i).getID() + "'");
				*/
				}
			}
				//broadcast activeChannels to each channel
			System.out.println("broadcasting activeChannels: "+activeChannels);
			String activeChannelsString = "";
			for(int i = 0; i < activeChannels.size();i++) {
				if(activeChannels.get(i) == true){
					activeChannelsString += channels.get(i).getName()+",";
				}
			}
			for(Broadcaster caster : broadcasters)
				caster.broadcast(Json.createObjectBuilder().add("activeChannels",activeChannelsString).build());
		
			

			System.out.println("While-loop went around!");
		}
	}

	// //////////////////////////////////////////////

}
