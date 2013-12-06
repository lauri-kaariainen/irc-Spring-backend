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

	@PreAuthorize("hasRole('2')")
	public abstract void updateChannel(String name);
	
	@PreAuthorize("hasRole('2')")
	public abstract Channel getChannel(String name);
	
	
}
