/**
 * 
 */
package com.laurikaariainen.nettiirkki.dao;

import com.laurikaariainen.nettiirkki.bean.Channel;

/**
 * Interface for working with Channels in database/file system.
 * @author lauri
 *
 */
public interface ChannelDao {
	
	/**
	 * Updates channel if channels lastChanged value is older than in DB
	 * @param name
	 * @return true if updated
	 */
	public abstract boolean updateChannel(Channel channel);

	/**
	 * Gets a Channel with up-to-date logs.
	 * @param name
	 * @return Channel with hopefully up-to-date log
	 */
	public abstract Channel getChannel(String name);

}
