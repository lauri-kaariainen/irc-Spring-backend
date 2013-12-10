/**
 * 
 */
package com.laurikaariainen.nettiirkki.bean;


import java.sql.Timestamp;

import javax.validation.constraints.Size;

/**
 * @author lauri
 *
 */
public class Channel {
	
	@Size(min = 3, max = 20)
	private String name;

	@Size(min = 1)
	private String text;

	private Timestamp lastChanged;
	
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getText() {
		return text;
	}

	public Timestamp getLastChanged() {
		return lastChanged;
	}

	public void setLastChanged(Timestamp lastChanged) {
		this.lastChanged = lastChanged;
	}

	public void setText(String text) {
		this.text = text;
	}
	
	

}
