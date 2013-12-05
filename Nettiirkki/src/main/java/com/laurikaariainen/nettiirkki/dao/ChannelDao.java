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
	 * Doesn't do anything just yet.
	 * @param name
	 */
	public abstract void updateChannel(String name);

	/**
	 * Gets a Channel with up-to-date logs.
	 * @param name
	 * @return Channel with hopefully up-to-date log
	 */
	public abstract Channel getChannel(String name);

}
