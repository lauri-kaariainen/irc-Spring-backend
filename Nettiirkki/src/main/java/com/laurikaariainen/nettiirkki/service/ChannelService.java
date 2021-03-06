/**
 * 
 */
package com.laurikaariainen.nettiirkki.service;

import org.springframework.security.access.prepost.PreAuthorize;

import com.laurikaariainen.nettiirkki.bean.Channel;



/**
 * @author lauri
 *
 */

public interface ChannelService {

	
	/**
	 * updates channel with recent text, if lastChanged is older than in the DB
	 * @param channel
	 * @return true if update did happen
	 */
	@PreAuthorize("hasRole('superman')")
	public abstract boolean updateChannel(Channel channel);
	
	/**
	 * loads a channel initially with text and all
	 * @param name
	 * @return channel
	 */
	@PreAuthorize("hasRole('superman')")
	public abstract Channel getChannel(String name);
	
	
}
