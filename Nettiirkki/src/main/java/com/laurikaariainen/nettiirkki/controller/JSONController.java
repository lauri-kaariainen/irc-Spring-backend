package com.laurikaariainen.nettiirkki.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.security.Principal;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;

import javax.inject.Inject;
import javax.json.Json;
import javax.json.JsonObject;
import javax.json.stream.JsonGenerator;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.laurikaariainen.nettiirkki.bean.Channel;
import com.laurikaariainen.nettiirkki.service.ChannelService;
import com.laurikaariainen.nettiirkki.service.ChannelUpdateAndBroadcastService;

import org.atmosphere.cpr.ApplicationConfig;
import org.atmosphere.cpr.AtmosphereResource;
import org.atmosphere.cpr.Broadcaster;
import org.atmosphere.cpr.BroadcasterFactory;
import org.atmosphere.cpr.FrameworkConfig;
import org.atmosphere.cpr.HeaderConfig;
import org.atmosphere.websocket.WebSocketEventListenerAdapter;




/**
 * Handles requests for the application home page.
 */
@Controller
public class JSONController {
	
	
	

	/**
	 * channels to be supported
	 * when adding channel, remember to make backend-related changes, ie. correct rights for files/dbs for server access
	 */
	private final static String[] CHANNELS = {"#otaniemi", "#punttis", "!3pyy", "#otapokeri", "laurikki","#synkkasiiseli", "!atkins.ry", "#polygame", "!patoteho", "#kokkikutonen" };
	
	@Inject
	private ChannelService channelService;
	

	
	private static final Logger logger = LoggerFactory.getLogger(JSONController.class);
	
	
	public static String[] getCHANNELS(){
		return CHANNELS;
	}
	
	/**
	 * Simply selects the home view to render by returning its name.
	 */
	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String home(Locale locale, Model model, HttpServletRequest request, Authentication authentication) {
		logger.info("Welcome home! The client locale is {}.", locale);
	
		
		Date date = new Date();
		DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG, locale);
		
		String formattedDate = dateFormat.format(date);
		
		model.addAttribute("serverTime", formattedDate );
		
		return "home";
	}
	


	/**
	 * TODO: preauthorized can't be used because async security doesn't still work
	 * Handles channel GETs for all channels in private array 'CHANNELS'
	 * Also updates via get parameters.
	 * * This method takes a request to subscribe to the topic
	 * @param name
	 * @param @pathvariable name, response, request
	 * @throws IOException
	 * 
	 */
	//@PreAuthorize("hasRole('superman')")
	@RequestMapping(value ="websocket/{name}", method = RequestMethod.GET)
	public void getChannel(@PathVariable String name,Model model, HttpServletResponse response, HttpServletRequest request, Principal principal, Authentication authentication) throws IOException{
		//response.setContentType("application/json");
		
		
		
		boolean wasFound = false;
		for (String channel : CHANNELS){
			if(channel.contains(name)) {
				name = channel;
				wasFound = true;
				break;
			}
		}
		if(wasFound == false){
			model.addAttribute("error", "Wrong channel");
			return;
		}
		
		//System.out.println("Authentication: "+authentication);
		//FWIW, THIS MUST BE DONE BECAUSE SECURITYCONTEXTHOLDER IS EMPTY WHEN METHOD IS REACHED VIA AJAX REQUEST !
		/*		    
		if(SecurityContextHolder.getContext().getAuthentication() == null){
			try {
			    SecurityContext ctx = SecurityContextHolder.createEmptyContext();
			    SecurityContextHolder.setContext(ctx);
			    ctx.setAuthentication(authentication);
			    System.out.println("Injected new context");
			}
		
			finally{
				System.out.println("Finished adding new securitycontextholder!");
				SecurityContextHolder.clearContext();
			}
		}
		  */
	    AtmosphereResource resource = (AtmosphereResource) request
                .getAttribute(FrameworkConfig.ATMOSPHERE_RESOURCE);
		//Proper subscribe to named channel!
		this.doGet(resource, request, resource.getResponse(),name);

		
		//Return json object with up-to-date text
		
		Channel channel = channelService.getChannel(name);
		JsonObject json = Json.createObjectBuilder().add("name",channel.getName()).
				add("text", channel.getText() ).
				add("timestamp",channel.getLastChanged().toString()).
				build();
		response.getWriter().print(json);
		response.getWriter().flush();
		
		return;
	}

	/**
	 * 
	 * @param name
	 * @param response
	 * @param request
	 * @throws IOException
	 * @deprecated
	 */
	
	//@RequestMapping(value ="websocket/{name}", method = RequestMethod.POST)
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
		Channel channel = channelService.getChannel(name);
		JsonObject json = Json.createObjectBuilder().add("name",channel.getName()).
				add("text", channel.getText() ).
				add("timestamp",channel.getLastChanged().toString()).
				build();
		
		 Broadcaster b = lookupBroadcaster(name);
         String message = request.getReader().readLine();
         
         
         
     	b.broadcast(json);
     	
        
        
		
		return;
		
	}
	
	

    // See AtmosphereHandlerPubSub example - same code as GET
    private void doGet(
                    AtmosphereResource resource,
                    HttpServletRequest req, HttpServletResponse res, String channelName) {
            // Log all events on the console, including WebSocket events.
            resource.addEventListener(new WebSocketEventListenerAdapter());

            //res.setContentType("text/html;charset=ISO-8859-1");
            res.setContentType("application/json");
            Broadcaster b = lookupBroadcaster(channelName);
            System.out.println("Signed in broadcaster with ID: '"+b.getID()+"'");
            resource.setBroadcaster(b);

            String header = req.getHeader(HeaderConfig.X_ATMOSPHERE_TRANSPORT);
            if (HeaderConfig.LONG_POLLING_TRANSPORT.equalsIgnoreCase(header)) {
                    req.setAttribute(ApplicationConfig.RESUME_ON_BROADCAST,
                                    Boolean.TRUE);
                    resource.suspend(-1);
            } else {
                    resource.suspend(-1);
            }
    }

    // See AtmosphereHandlerPubSub example - same code as POST
    /**
     * 
     * @param req
     * @param channel
     * @throws IOException
     * @deprecated
     */
    private void doPost(HttpServletRequest req, Channel channel) throws IOException {
            Broadcaster b = lookupBroadcaster(req.getRequestURI());
            String message = req.getReader().readLine();
            
            if (message != null && message.indexOf("message") != -1) {
            	//b.broadcast(message.substring("message=".length()));
            	b.broadcast(channel);
            }
    }

    /**
     * Retrieve the {@link Broadcaster} based on the request's path info.
     * 
     * @param pathInfo
     * @return the {@link Broadcaster} based on the request's path info.
     */
    Broadcaster lookupBroadcaster(String pathInfo) {
	    if (pathInfo == null) {
	        return BroadcasterFactory.getDefault().lookup("/", true);
	    } else {
	        String[] decodedPath = pathInfo.split("/");
	        return BroadcasterFactory.getDefault().lookup(
	                decodedPath[decodedPath.length - 1], true);
	    }
    }

   
}