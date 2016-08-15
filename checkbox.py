# -*- coding: utf-8 -*-
from selenium import webdriver
import os
import time
driver = webdriver.Firefox()
file_path = 'file:///' + os.path.abspath('checkbox.html')
driver.get(file_path)
inputs = driver.find_elements_by_tag_name('input')

for input in inputs:
    if input.get_attribute('type') == 'checkbox':
       input.click()
        
        
time.sleep(10)
driver.quit()
