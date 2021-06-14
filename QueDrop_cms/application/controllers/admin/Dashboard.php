<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Dashboard extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();
		$this->load->model('common_model', 'common');
		$this->load->model('driver_model', 'driver');
		$this->load->model('user_model', 'user');
	}

	/**
	 * Loads the admin dashboard
	 */
	public function index()
	{  
		$this->set_page_title(_l('dashboard')); 
		$data['users'] = $this->user->get_users();
		$data['drivers'] = $this->driver->get_driver();
		// $data['suppliers'] = $this->common->get_all('suppliers');
		$data['stores'] = $this->common->get_all('store');
		// $data['coupons'] = $this->common->get_all('coupons');
		$data['orders'] = $this->common->get_all('orders');
		$data['products'] = $this->common->get_all('product');
		$data['offers'] = $this->common->get_all('admin_offers');
		$data['categories'] = $this->common->get_all('store_food_category');
		$data['content'] = $this->load->view('admin/dashboard/index', $data, TRUE);
		$this->load->view('admin/layouts/index', $data);

	}
}
