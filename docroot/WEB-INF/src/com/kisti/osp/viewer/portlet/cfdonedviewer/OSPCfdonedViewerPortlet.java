package com.kisti.osp.viewer.portlet.cfdonedviewer;

import java.io.IOException;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import com.kisti.osp.service.OSPFileLocalServiceUtil;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.util.bridges.mvc.MVCPortlet;

/**
 * Portlet implementation class OSPCfdonedViewerPortlet
 */
public class OSPCfdonedViewerPortlet extends MVCPortlet {
    private static Log _log = LogFactoryUtil.getLog(OSPCfdonedViewerPortlet.class);

    @Override
    public void doView(RenderRequest renderRequest, RenderResponse renderResponse) throws IOException, PortletException{

        super.doView(renderRequest, renderResponse);
    }

    @Override
    public void serveResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
        throws IOException, PortletException{
    	OSPFileLocalServiceUtil.processOSPResourceAction(resourceRequest, resourceResponse);
    }
}
