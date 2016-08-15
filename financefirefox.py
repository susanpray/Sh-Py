# -*- coding: UTF-8 -*-
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import NoSuchElementException
import unittest
import time
import re


class Finance(unittest.TestCase):
    def setUp(self):
        self.driver = webdriver.Firefox()
        self.driver.implicitly_wait(30)
        self.base_url = "http://zpre.cnsuning.com/"
        self.verificationErrors = []
        self.accept_next_alert = True

    def test_finance(self):
        driver = self.driver
        driver.get(self.base_url + "/")
        driver.find_element_by_link_text(u"登录").click()
        driver.find_element_by_id("userName").clear()
        driver.find_element_by_id("userName").send_keys("15295568019")
        driver.find_element_by_id("password").clear()
        driver.find_element_by_id("password").send_keys("123qwe")
        driver.find_element_by_id("submit").click()
        driver.find_element_by_link_text(u"发起项目").click()
        # driver.find_element_by_css_selector("btn-argee").click()
        driver.find_element_by_xpath(u"//a[contains(text(),'阅读并同意协议')]").click()
        # driver.find_element_by_xpath("//a[@href='/project/add.htm']").click()
        # driver.find_element_by_class_name("btn-argee").click()
        # driver.find_element_by_xpath("/html/body/div[4]/div/div/div[2]/a").click()
        # driver.find_element_by_link_text(u"阅读并同意协议").click()
        driver.find_element_by_name("projectName").clear()
        driver.find_element_by_name("projectName").send_keys(u"susan众筹002")
        driver.find_element_by_name("introduction").clear()
        driver.find_element_by_name("introduction").send_keys(u"susan众筹002")
        driver.find_element_by_name("needAmountY").clear()
        driver.find_element_by_name("needAmountY").send_keys("1000")
        driver.find_element_by_name("days").clear()
        driver.find_element_by_name("days").send_keys("10")
        driver.find_element_by_id("rUpload").clear()
        driver.find_element_by_id("rUpload").send_keys(u"E:\\测\\图\\000000000103930098_2_800x800.jpg")
        driver.find_element_by_name("selfIntro").clear()
        driver.find_element_by_name("selfIntro").send_keys(u"susan众筹002")
        driver.find_element_by_name("detailIntro").clear()
        driver.find_element_by_name("detailIntro").send_keys(u"susan众筹002")
        driver.find_element_by_name("weibo").clear()
        driver.find_element_by_name("weibo").send_keys(u"susan众筹002")
        driver.find_element_by_name("phone").clear()
        driver.find_element_by_name("phone").send_keys(u"susan众筹002")
        driver.find_element_by_link_text(u"下一步").click()
        driver.find_element_by_name("phone").clear()
        driver.find_element_by_name("phone").send_keys("13951726249")
        driver.find_element_by_link_text(u"下一步").click()
        driver.find_element_by_id("amountY").clear()
        driver.find_element_by_id("amountY").send_keys("500")
        driver.find_element_by_id("rUpload").clear()
        driver.find_element_by_id("rUpload").send_keys(u"E:\\测\\图\\000000000103930098_2_800x800.jpg")
        driver.find_element_by_id("introduction").clear()
        driver.find_element_by_id("introduction").send_keys(u"susan众筹001")
        driver.find_element_by_id("period").clear()
        driver.find_element_by_id("period").send_keys("5")
        driver.find_element_by_link_text(u"确定").click()
        driver.find_element_by_css_selector("i.icon-radio.icon-radio-selected").click()
        driver.find_element_by_link_text(u"确定").click()
        driver.find_element_by_link_text(u"下一步").click()
        driver.find_element_by_link_text(u"提交").click()
        driver.find_element_by_link_text(u"项目总览").click()
        driver.find_element_by_css_selector("a[name=\"zc_browseList_select_13\"] > span").click()
        driver.find_element_by_css_selector("a[name=\"zc_browseList_select_14\"] > span").click()
        driver.find_element_by_link_text(u"退出登录").click()
    
    def is_element_present(self, how, what):
        try:
            self.driver.find_element(by=how, value=what)
        except NoSuchElementException:
            return False
        return True
    
    def is_alert_present(self):
        try:
            self.driver.switch_to.alert()
        except NoAlertPresentException:
            return False
        return True
    
    def close_alert_and_get_its_text(self):
        try:
            alert = self.driver.switch_to.alert()
            alert_text = alert.text
            if self.accept_next_alert:
                alert.accept()
            else:
                alert.dismiss()
            return alert_text
        finally:
            self.accept_next_alert = True
    
    def tearDown(self):
        self.driver.quit()
        self.assertEqual([], self.verificationErrors)

if __name__ == "__main__":
    unittest.main()
