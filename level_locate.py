from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.action_chains import ActionChains
import time
import os
driver = webdriver.Firefox()
file_path = 'file:///' + os.path.abspath('level_locate.html')
driver.get(file_path)
driver.find_element_by_link_text('Link1').click()
menu = driver.find_element_by_id('dropdown1').find_element_by_link_text('Another action')
ActionChains(driver).move_to_element(menu).perform()
time.sleep(5)
driver.quit()
