<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold">View Store Payments</span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
			</li>
			<li>
				<a href="<?php echo base_url('admin/payments/view'); ?>">Store Payments</a>
			</li>
			<li class="active"><?php _el('view'); ?></li>
		</ul>
	</div>
</div>
<!-- Page header -->
<!-- Content area -->
<div class="content">	
	<form id="drivr" action="<?php echo base_url('admin/payments/confirm_store/').$store['store_id']; ?>" method="POST">
		<div class="row">
		    <input type="hidden" name="id" value="<?php echo $store['store_id'];?>">
			<input type="hidden" name="is_store" value="1">
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Store Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
							<?php if(!empty($store)) {	?>
									<div class="col-md-12">
										<div>
											<span><b>Name:</b> <?php echo $store['store_name'];?></span><br>
											<span><b>Address:</b> <?php echo $store['store_address'];?></span><br>
										</div>
									</div>
											
									<?php }?>
						</div>
					</div>
				</div>
			</div>
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Order Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
                        <?php if(!empty($store_orders)) {
							foreach($store_orders as $orders){ 
								$order_ids[] =  $orders['order_id'];
								$total_amount[] = $orders['order_amount']; 
							}	?>
                        <div class="col-md-12">
                            <div>
                                <?php if(!empty($store_orders)){
                                ?>
                                <table id="account_details">
                                    <tr>
                                        
                                        <th>Order Id</th>
                                        <th>Order Amount</th>
										<th>Store Amount</th>
                                        <th>Order Date</th>
                                    </tr>
									<tbody style='height:50px;overflow:auto;'>
									<?php $i=0; 
										$len = count($store_orders);
										foreach($store_orders as $orders){ $i++;
											$store_amount = 0;
											
											if(!empty($order_data[$orders['order_id']])) { 
												// echo "<pre>"; print_r($order_data[$orders['order_id']]);
												foreach($order_data[$orders['order_id']]->data->order_billing_details->billing_detail->registered_stores as $stor_da){
													if($stor_da->store_name == $store['store_name']) {
														$store_amount = $stor_da->store_amount;
														$toatl_store[] = $store_amount;
													}
												}
												$total_pay = $order_data[$orders['order_id']]->data->order_billing_details->billing_detail->total_pay;
											} 
											$total_amount[] = $orders['order_amount'];
                                        ?>
                                    <tr>
                                    
                                    <td><?php echo "#".$orders['order_id'];?></td>
                                        <td><?php echo "$".$total_pay;?></td>
										<td><?php echo "$".$store_amount;?></td>
                                        <td><?php echo date('m-d-Y', strtotime($orders['created_at']))  ;?></td>
                                    </tr>
									<?php
										}
										if(!empty($toatl_store)){
											$total = array_sum($toatl_store);
										} else {
											$total = 0;
										}
                                    ?>
									<tr>
									 <td>
									 <span>Total Order: <b><?php echo count($store_orders);?></b></span><br>
									 </td>
									 <td></td>
									 <td><span>Total Store Amount: <b><?php echo "$".$total;?></b></span><br></td>
									 <td></td>
									</tr>
									</tbody>
                                </table>
                                <?php
								$order_ids = implode(',',$order_ids); 
                                }
                                
                                ?>
								<input type="hidden" name="order_ids" value="<?php echo $order_ids;?>">
                            </div>
                        </div>
                                
                        <?php } else {
							?>
								<span><b>Order details not available</b></span>
							<?php
						}?>
						</div>
					</div>
				</div>
			</div>

			
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Bank Account Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
						<?php if(!empty($account_details)){
                                    ?>
                                        <table id="account_details">
                                            <tr>
                                                <th>Bank Name</th>
                                                <th>Account Number</th>
                                                <th>IFSC Code</th>
                                                <th>Account Type</th>
                                            </tr>
                                    <?php
                                    foreach($account_details as $account){
										$account_number = openssl_decrypt($account['account_number'],"AES-128-ECB",'3e87547b9029d3f35fc06b45fee93ebb');
                                        $ifsc_code = openssl_decrypt($account['ifsc_code'],"AES-128-ECB",'3e87547b9029d3f35fc06b45fee93ebb');
                                    ?>
                                    <tr>
                                        <td><?php echo $account['bank_name'];?></td>
                                        <td><?php echo $account_number;?></td>
                                        <td><?php echo $ifsc_code;?></td>
                                        <td><?php echo $account['account_type'];?></td>
                                    </tr>
                                    <?php
									}
								?>
								</table>
								<?php
                                } else {
								 ?>
								 <span><b>Bank Account Details not available</b></span>
								 <?php
								}?>
						</div>
					</div>
				</div>
			</div>

			<?php if(!empty($store_orders)) { ?>
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Confirm Payment</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
					<div class="row">
                                <?php
                                 if (!empty($start_date)) {
                                    ?><input type="hidden" name="start_date" value="<?php echo date('Y-m-d', strtotime($start_date));?>"><?php
                                    } 
                                    if(!empty($end_date)) {
                                    ?><input type="hidden" name="end_date" value="<?php echo date('Y-m-d', strtotime($end_date));?>"><?php
                                    }
                                ?>
								<span class="pay_class"><b class="ti_cl">Actual Amount to Pay :</b>
								<input type="text" name="actual_amount" id="ac_amount" class="form-control" placeholder="Ex:200" value="<?php if(!empty($confirm_details['actual_amount_pay'])){echo $confirm_details['actual_amount_pay'];}?>"></span><br>
								<span class="pay_class"><b class="ti_cl">Add Comment :</b><input type="text" name="comment" placeholder="Comment" class="form-control" value="<?php if(!empty($confirm_details['comment'])){echo $confirm_details['comment'];}?>"></span><br>
								<span class="pay_class"><b class="ti_cl" style="width:20%;">Confirm Payment to Store : </b>
								<input type="checkbox" name="con_dri" class="styled" id="confirm_store_payment" <?php if(!empty($confirm_details)){
                                    if($confirm_details['confirm_payment'] == 1){
                                        echo "checked";
                                    }
                                }?>></span><br>
                                <?php if(!empty($confirm_details)){
                                    ?>
                                    <input type="hidden" name="week_id" value="<?php echo $confirm_details['id'];?>">
                                    <?php
                                }?>
						</div>
					</div>
				</div>
			</div>
			<?php } ?>

		</div>	
		<div class="btn-bottom-toolbar text-right btn-toolbar-container-out">
			<?php if(!empty($store_orders)) { ?><button type="submit" class="btn btn-success verify_submit" name="submit"><?php _el('save'); ?></button><?php }?>
			<a class="btn btn-default" onclick="window.history.back();"><?php _el('back'); ?></a>
		</div>
	</form>
</div>
<!-- /Content area -->
<style>
.ti_cl{width:25%;}
.pay_class{
	display: inline-flex;
    width: 100%;
	margin-top: 1%;
}
#account_details {
  font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

#account_details td, #account_details th {
  border: 1px solid #ddd;
  padding: 8px;
}

#account_details tr:nth-child(even){background-color: #f2f2f2;}

#account_details tr:hover {background-color: #ddd;}

#account_details th {
  padding-top: 12px;
  padding-bottom: 12px;
  text-align: left;
  background-color: #26A69A;
  color: white;
}
</style>
<script type="text/javascript" src="../../../../Socket/node_modules/socket.io-client/dist/socket.io.js"></script>
<script>
$("#drivr").submit(function(e) {
	if($("#ac_amount").val() == ''){
        jGrowlAlert("Actual Payment amount is required", 'danger');
        return false;
    }

e.preventDefault(); // avoid to execute the actual submit of the form.

var form = $(this);
var url = form.attr('action');
$.ajax({
       type: "POST",
       url: url,
       data: form.serialize(), // serializes the form's elements.
       success: function(data)
       {
            if($("#confirm_store_payment").is(":checked")){
                var socket = io.connect('http://clientapp.narola.online:8081'); 
                var data = {
                    driver_id : 0,
                    is_driver : 0,
                    store_id : '<?php echo $store['store_id'];?>',
                    store_owner_id : '<?php echo $store['user_id'];?>',
                    weekly_payment_id : data,
                    week_start_date : '<?php echo date('Y-m-d', strtotime($start_date));?>',
                    week_end_date : '<?php echo date('Y-m-d', strtotime($end_date));?>'
                };
                socket.emit('confirm_weekly_payment', data, function(callBack) {
					console.log(callBack);
                }) ; 
            }
            // show response from the php script.
            jGrowlAlert("Payment Confirmed Successfully", 'success');
			setTimeout(function(){ window.location.href = '<?php echo base_url();?>admin/payments/view'; }, 5000);
            
       }
     });
});

</script>




