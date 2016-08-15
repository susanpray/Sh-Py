
from selenium import webdriver
import os,time
source = open("E:\python script\data.txt", "r")
values = source.readlines()
source.close()
for value in values:
    #browser = webdriver.Firefox()
    driver = "C:\Python27\IEDriverServer.exe"
    os.environ["webdriver.ie.driver"] = driver
    browser = webdriver.Ie(driver)
    browser.get("http://www.baidu.com")
    browser.find_element_by_id("kw").send_keys(value)
    browser.find_element_by_id("su").click()
    browser.quit()




