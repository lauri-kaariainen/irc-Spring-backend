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

	@PreAuthorize("hasRole('superman')")
	public abstract void updateChannel(String name);
	
	@PreAuthorize("hasRole('superman')")
	public abstract Channel getChannel(String name);
	
	
}
