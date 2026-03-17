package com.wuzijie.wzjaicodemother.service.impl;

import com.wuzijie.wzjaicodemother.innerservice.InnerScreenshotService;
import com.wuzijie.wzjaicodemother.service.ScreenshotService;
import jakarta.annotation.Resource;
import org.apache.dubbo.config.annotation.DubboService;

@DubboService
public class InnerScreenshotServiceImpl implements InnerScreenshotService {

    @Resource
    private ScreenshotService screenshotService;

    @Override
    public String generateAndUploadScreenshot(String webUrl) {
        return screenshotService.generateAndUploadScreenshot(webUrl);
    }
}