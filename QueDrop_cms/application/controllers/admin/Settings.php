<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Settings extends Admin_Controller
{
	/**
	 * Constructor for the class
	 */
	public function __construct()
	{
		parent::__construct();
		$this->load->model('common_model', 'common');
		$this->load->model('setting_model', 'setting');
	}

	/**
	 * Loads the settings page
	 */
	public function index()
	{
		$this->set_page_title(_l('settings'));
		$settings = $this->setting->get_values();
		$data['settings'] = $settings[0];
		$data['content']  = $this->load->view('admin/settings/index', $data, TRUE);
		$this->load->view('admin/layouts/index', $data);
	}

	public function edit($id = '')
	{
		if ($id)
		{
			if ($this->input->post())
			{
				$data = array(
					'service_charge'=>$this->input->post('service_charge'),
					'minimum_delivery_charge'=>$this->input->post('minimum_delivery_charge'),
					'shopping_fee'=>$this->input->post('shopping_fee'),
					'shopping_fee_percentage'=>$this->input->post('shopping_fee_per'),
					'minimum_transport_time'=>$this->input->post('minimum_transport_time'),
					'driver_search_radius'=>$this->input->post('driver_search_radius'),
					'order_request_waiting_time'=>$this->input->post('order_request_waititng_time'),
					'order_request_accept_time'=>$this->input->post('order_request_accept_time'),
					'per_minute_delivery_charge'=>$this->input->post('delivery_charge_per_minute'),
					'per_minute_express_delivery_charge'=>$this->input->post('per_minute_express_delivery_charge'),
					'minimum_express_delivery_charge'=>$this->input->post('minimum_express_delivery_charge'),
				);
				$where = array('config_id'=>$id);
				
				$update = $this->common->update($data,$where,'values_config');
				if ($update)
				{
					set_alert('success', _l('_updated_successfully', _l('settings')));
					log_activity("User Updated [ID: $id]");
					redirect('admin/settings');
				}
			}
		}
	}
}
