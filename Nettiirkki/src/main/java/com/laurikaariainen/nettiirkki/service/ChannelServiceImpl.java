/**
 * 
 */
package com.laurikaariainen.nettiirkki.service;

import javax.inject.Inject;

import org.springframework.stereotype.Service;

import com.laurikaariainen.nettiirkki.bean.Channel;
import com.laurikaariainen.nettiirkki.dao.ChannelDao;

/**
 * @author lauri
 *
 */
@Service
public class ChannelServiceImpl implements ChannelService{

	@Inject 
	private ChannelDao channelDao;
	
	@Override
	public boolean updateChannel(Channel channel) {
		return channelDao.updateChannel(channel);
		
	}

	@Override
	public Channel getChannel(String string) {
		return channelDao.getChannel(string);
	}

	
	
	

}
