package com.laurikaariainen.nettiirkki.util;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.atmosphere.cpr.ApplicationConfig;
import org.atmosphere.cpr.AtmosphereResource;
import org.atmosphere.cpr.Broadcaster;
import org.atmosphere.cpr.BroadcasterFactory;
import org.atmosphere.cpr.HeaderConfig;
import org.atmosphere.cpr.Meteor;
import org.atmosphere.websocket.WebSocketEventListenerAdapter;


public class MeteorPubSub extends HttpServlet {

    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse res)
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

    public void doPost(HttpServletRequest req, HttpServletResponse res)
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

}