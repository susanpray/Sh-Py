#coding=utf-8
from selenium import webdriver
driver=webdriver.Firefox()
path="http://www.baidu.com"
driver.get(path)
try:
   driver.find_element_by_id("kwsss").send_keys("selenium")
   driver.find_element_by_id("su").click()
except:
   driver.get_screenshot_as_file("E:\python script\sceenshot1.png")

driver.quit()





