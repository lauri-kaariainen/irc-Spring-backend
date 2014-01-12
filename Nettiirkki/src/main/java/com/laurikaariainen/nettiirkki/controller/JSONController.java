package com.laurikaariainen.nettiirkki.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import javax.inject.Inject;
import javax.json.Json;
import javax.json.stream.JsonGenerator;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.laurikaariainen.nettiirkki.bean.Channel;
import com.laurikaariainen.nettiirkki.service.ChannelService;


import org.atmosphere.cpr.ApplicationConfig;
import org.atmosphere.cpr.AtmosphereResource;
import org.atmosphere.cpr.Broadcaster;
import org.atmosphere.cpr.BroadcasterFactory;
import org.atmosphere.cpr.FrameworkConfig;
import org.atmosphere.cpr.HeaderConfig;
import org.atmosphere.cpr.Meteor;
import org.atmosphere.websocket.WebSocketEventListenerAdapter;



/**
 * Handles requests for the application home page.
 */
@Controller
public class JSONController {
	
	
	

	/**
	 * channels to be supported
	 */
	private final String[] CHANNELS = {"#otaniemi", "#punttis", "!3pyy", "#otapokeri" };
	
	@Inject
	private ChannelService channelService;
	
	private static final Logger logger = LoggerFactory.getLogger(JSONController.class);
	
	/**
	 * Simply selects the home view to render by returning its name.
	 */
	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String home(Locale locale, Model model) {
		logger.info("Welcome home! The client locale is {}.", locale);
		
	
		Date date = new Date();
		DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG, locale);
		
		String formattedDate = dateFormat.format(date);
		
		model.addAttribute("serverTime", formattedDate );
		
		return "home";
	}
	
	/**
	 * Handles channel GETs for all channels in private array 'CHANNELS'
	 * Also updates via get parameters.
	 * @param name
	 * @param @pathvariable name, response, request
	 * @throws IOException
	 */
	
/*
	@RequestMapping(value ="/{name}", method = RequestMethod.GET)
	public void getChannel(@PathVariable String name, HttpServletResponse response, HttpServletRequest request) throws IOException{
		response.setContentType("application/json");
		
		
		boolean wasFound = false;
		for (String channel : CHANNELS){
			if(channel.contains(name)) {
				name = channel;
				wasFound = true;
				break;
			}
		}
		if(wasFound == false)
			return;
		
		
		
		Channel returnChannel;
		
		//GET parameter UPDATE called
		if(request.getParameter("update") != null){
			
			long age = Long.parseLong(request.getParameter("update"));
			Channel c = new Channel();
			c.setName(name);
			c.setLastChanged(new Timestamp(age));
			if(channelService.updateChannel(c)){
				returnChannel = c;
				
				
				System.out.println("did indeed update");	
				
			}
			else { // no update necessary, send 304 NOT CHANGED back
				response.setStatus(304);
				System.out.println("did indeed cancel");
				return;
			}
			
		}
		else {  // Nobody wanted to update, just get the channel
			returnChannel = channelService.getChannel(name);
		}
		
		PrintWriter out = response.getWriter();
		
		JsonGenerator gen = Json.createGenerator(out);
		
		
	
		gen.writeStartObject();
		
		gen.write("name", returnChannel.getName());
		gen.write("text", returnChannel.getText());
		gen.write("timestamp", returnChannel.getLastChanged().getTime());
		
		
		
		gen.writeEnd();
		
		gen.close();
		return;
	}

*/
	/**
	 * Handles channel GETs for all channels in private array 'CHANNELS'
	 * Also updates via get parameters.
	 * * This method takes a request to subscribe to the topic
	 * @param name
	 * @param @pathvariable name, response, request
	 * @throws IOException
	 */
	
	@RequestMapping(value ="websocket/{name}", method = RequestMethod.GET)
	public void getChannel(@PathVariable String name, HttpServletResponse response, HttpServletRequest request) throws IOException{
		response.setContentType("application/json");
		
		
		boolean wasFound = false;
		for (String channel : CHANNELS){
			if(channel.contains(name)) {
				name = channel;
				wasFound = true;
				break;
			}
		}
		if(wasFound == false)
			return;
		
		
		doGet(request, response);
		
	
        /*
        Channel returnChannel;
		
		//GET parameter UPDATE called
		if(request.getParameter("update") != null){
			
			long age = Long.parseLong(request.getParameter("update"));
			Channel c = new Channel();
			c.setName(name);
			c.setLastChanged(new Timestamp(age));
			if(channelService.updateChannel(c)){
				returnChannel = c;
				
				
				System.out.println("did indeed update");	
				
			}
			else { // no update necessary, send 304 NOT CHANGED back
				response.setStatus(304);
				System.out.println("did indeed cancel");
				return;
			}
			
		}
		else {  // Nobody wanted to update, just get the channel
			returnChannel = channelService.getChannel(name);
		}
		
		PrintWriter out = response.getWriter();
		
		JsonGenerator gen = Json.createGenerator(out);
		
		
	
		gen.writeStartObject();
		
		gen.write("name", returnChannel.getName());
		gen.write("text", returnChannel.getText());
		gen.write("timestamp", returnChannel.getLastChanged().getTime());
		
		
		
		gen.writeEnd();
		
		gen.close();
         */
		return;
	}

	@RequestMapping(value ="websocket/{name}", method = RequestMethod.POST)
	public void broadcastToChannel(@PathVariable String name, HttpServletResponse response, HttpServletRequest request) throws IOException{
		//response.setContentType("application/json");
		
		
		boolean wasFound = false;
		for (String channel : CHANNELS){
			if(channel.contains(name)) {
				name = channel;
				wasFound = true;
				break;
			}
		}
		if(wasFound == false)
			return;
		
		
		doPost(request, response);
		
	}
	
	
	 private void doGet(HttpServletRequest req, HttpServletResponse res)
		       throws IOException {
        // Create a Meteor
        Meteor m = Meteor.build(req);

        // Log all events on the console, including WebSocket events.
        m.addListener(new WebSocketEventListenerAdapter());

        res.setContentType("text/html;charset=ISO-8859-1");

        Broadcaster b = lookupBroadcaster(req.getRequestURI());
        m.setBroadcaster(b);

        if (req.getHeader(HeaderConfig.X_ATMOSPHERE_TRANSPORT)
                .equalsIgnoreCase(HeaderConfig.LONG_POLLING_TRANSPORT)) {
            req.setAttribute(ApplicationConfig.RESUME_ON_BROADCAST, Boolean.TRUE);
            m.suspend(-1,null);
        } else {
            m.suspend(-1);
        }
	 }
	 private void doPost(HttpServletRequest req, HttpServletResponse res)
		        throws IOException {
    	System.out.println("inside doPost in Bean");
        Broadcaster b = lookupBroadcaster(req.getRequestURI());
        String message = req.getReader().readLine();

        if (message != null && message.indexOf("message") != -1) {
        	System.out.println("broadcasting:"+message);
            b.broadcast(message.substring("message=".length()));
            System.out.println("broadcasted:"+message);
        }
        else
	        	System.out.println("message was not printed b/c it didn't exist!");
    }

    Broadcaster lookupBroadcaster(String pathInfo) {
        String[] decodedPath = pathInfo.split("/");
        Broadcaster b = BroadcasterFactory.getDefault()
              .lookup(decodedPath[decodedPath.length - 1], true);
        return b;
    }
	
	
	
	/**
	 * handles requests for channel #otaniemi
	 * @param model
	 * @return view 'channel'
	 * @deprecated
	 */
	/*
	@RequestMapping(value ="/otaniemi", method = RequestMethod.GET)
	public String getOtaniemi(Model model){
		
		Channel channel = channelService.getChannel("#otaniemi");
		System.out.println("*"+channel.getText()+"*");
		model.addAttribute("channel", channel);
		
		return "channel";
	}
	*/
	/**
	 * handles requests for channel #punttis
	 * @param model
	 * @return view 'channel'
	 * @throws IOException 
	 * @deprecated
	 */
	/*
	@RequestMapping(value ="/punttis", method = RequestMethod.GET)
	public void getpunttis(Model model, HttpServletResponse response) throws IOException{
		response.setContentType("application/json");
		PrintWriter out = response.getWriter();
		
		JsonGenerator gen = Json.createGenerator(out);
		
		Channel channel = channelService.getChannel("#punttis");
		//System.out.println("*"+channel.getText()+"*");
		//model.addAttribute("channel", channel);
		
		//gen.writeStartArray();
		
		gen.writeStartObject();
		
		gen.write("name", channel.getName());
		gen.write("text", channel.getText());
		gen.write("timestamp", channel.getLastChanged().toString());
		
		
		
		gen.writeEnd();
		
		gen.close();
		return;
	}

*/	
	
	/**
	 * handles requests for channel !3pyy
	 * @param model
	 * @return view 'channel'
	 * @deprecated
	 */
	/*
	@RequestMapping(value ="/3pyy", method = RequestMethod.GET)
	public String get3pyy(Model model){
		
		Channel channel = channelService.getChannel("!3pyy");
		System.out.println("*"+channel.getText()+"*");
		model.addAttribute("channel", channel);
		
		return "channel";
	}
	
	 */
}