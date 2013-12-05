/**
 * 
 */
package com.laurikaariainen.nettiirkki.service;

import com.laurikaariainen.nettiirkki.bean.Channel;



/**
 * @author lauri
 *
 */

public interface ChannelService {

	//@PreAuthorize("isAuthenticated()")
	public abstract void updateChannel(String name);
	
	//@PreAuthorize("isAuthenticated()")
	public abstract Channel getChannel(String name);
	
	
}
