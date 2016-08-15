#coding=utf-8
from selenium import webdriver
import time
import os
driver = webdriver.Chrome()
driver.get("http://zpre.cnsuning.com")

driver.find_element_by_link_text("登录").click()
time.sleep(10)
div = driver.find_element_by_class_name("tang-pass-login").find_element_by_name("userName")
div.send_keys("username")
driver.find_element_by_name("password").send_keys("password")
driver.find_element_by_id("TANGRAM__PSP_8__submit").click()
driver.quit()
