# -*- coding: UTF-8 -*-
import os
import time
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
#导入WebDriverWait 包
from selenium.webdriver.support.ui import WebDriverWait 
browse = webdriver.Chrome()
browse.get("http://prezc.cnsuning.com/")
#browse.get("http://www.baidu.com")
#browse.find_element_by_id("kw").send_keys("selenium")
#browse.find_element_by_id("kw").send_keys(Keys.CONTROL,'a')
#browse.find_element_by_id("kw").send_keys("selenium")
#browse.find_element_by_id("su").click()
#time.sleep(20)
#size=browse.find_element_by_id("kw").size
#print size
#move = browse.find_element_by_xpath("//div[@class='ng-bar-node-box myorder-handle']/a/span")
#ActionChains(browse).move_to_element(move).perform()
browse.find_element_by_link_text(u"登录").click()
time.sleep(10)
browse.find_element_by_id("userName").send_keys("15295568019")
browse.find_element_by_id("password").send_keys("123qwe")
time.sleep(20)
browse.find_element_by_link_text(u"登　录").click()
time.sleep(10)
#title = browse.title()
#print title
now_url = browse.current_url
print now_url

#time.sleep(20)
#添加智能等待
driver.implicitly_wait(30)
browse.quit()
