<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold"><?php _el('view_orders'); ?></span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
			</li>
			<li>
				<a href="<?php echo base_url('admin/orders'); ?>"><?php _el('orders'); ?></a>
			</li>
			<li class="active"><?php _el('view'); ?></li>
		</ul>
	</div>
</div>
<!-- Page header -->
<!-- Content area -->
<div class="content">	
	<form id="orderform" action="<?php echo base_url('admin/orders/payment/').$order['order_id']; ?>" method="post">
		<div class="row">
			<div class="col-md-6 ">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Customer Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<!-- /Panel heading -->
					<!-- Panel body -->
					<div class="panel-body">
						<div class="row">
							<div class="col-md-12">
								<span><b>Name: </b>  <?php echo $order['first_name']." ".$order['last_name'];?></span><br>
                                <span><b>Delivery Address:</b> <?php echo $order['delivery_address'];?></span><br>
                                <span><b> Email:</b> <?php echo $order['email'];?></span><br>
                                <span><b>Phone No:</b> <?php echo $order['phone_number'];?></span><br>
								<span></span><br>
                                <span></span><br>
							 </div>
						</div>
					</div>
					<!-- /Panel body -->
				</div>
				<!-- /Panel -->
			</div>
			<div class="col-md-6 ">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Order Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<!-- /Panel heading -->
					<!-- Panel body -->
					<div class="panel-body">
						<div class="row">
							<div class="col-md-12">
								<span><b>Order Amount:</b> <?php echo "$".$order['order_amount'];?></span><br>
                                <span><b>Delivery Charge:</b> <?php echo "$".$order['delivery_charge'];?></span><br>
                                <span><b>Service Charge:</b> <?php echo "$".$order['service_charge'];?></span><br>
                                <span><b>Order Total Amount:</b> <?php echo "$".$order['order_total_amount'];?></span><br>
                                <span><b>Driver Note:</b> <?php echo $order['driver_note'];?></span><br>
                                <span><b>Order Status:</b> <?php echo $order['order_status'];?></span><br>
                                <span><b>Delivery Option:</b> <?php echo $order['delivery_option'];?></span><br>
                             </div>
						</div>
					</div>
					<!-- /Panel body -->
				</div>
				<!-- /Panel -->
			</div>
			<?php if(!empty($driver)) { ?>
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Driver Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
							<div class="col-md-12">
								<span><b>Driver Name:</b> <?php echo $driver['first_name']." ".$driver['last_name'] ;?></span><br>
                                <span><b>Driver Email:</b> <?php echo $driver['email'];?></span><br>
                                <span><b>Driver Phone Number:</b> <?php echo $driver['phone_number'];?></span><br>
                                <span><b>Driver Address:</b> <?php echo $driver['address'];?></span><br>
                            </div>
						</div>
					</div>

				</div>
			</div>
			<?php } ?>
			
			<?php
			
			if(!empty($pro_details)) {
			?>
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Product Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
							<?php 
								if(!empty($pro_details['stores'])) {
									foreach($pro_details['stores'] as $stores) { 
									?>
								<div class="panel panel-flat">
									<div class="panel-body">
										<div class="row">
										<div class="col-md-12">
										<div>
											<span><b>Store Name:</b> <?php echo $stores['store_name'];?></span><br>
											<span><b>Store Address:</b> <?php echo $stores['store_address'];?></span><br>
											<span><b>Store Type:</b><?php echo $stores['store_type'];?></span><br>
										</div>
									</div>	<?php
												if(!empty($stores['store_products'])) {
													foreach($stores['store_products'] as $products) {
														?>
													<div class="col-md-12">
													<div class="col-md-4">
														<?php if(!empty($products['product_image'])) {?>
														<div class="thumbnail">
															<div class="thumb">
																<img src="<?php echo VIEW_PRODUCTS.$products['product_image'];?>" alt="" style="height: 240px;">
																<div class="caption-overflow">
																	<span>
																		<a href="<?php echo VIEW_PRODUCTS.$products['product_image'];?>" data-popup="lightbox" class="btn border-white text-white btn-flat btn-icon btn-rounded"><i class="icon-plus3"></i></a>
																	</span>
																</div>
															<div class="caption">
																<h6 class="no-margin">
																	<a href="#" class="text-default"><?php echo $products['product_name']?></a> 
																	<a href="#" class="text-muted"><i class="icon-three-bars pull-right"></i></a>
																</h6>
															</div>
														</div>
														</div> <?php } else { echo "Product Image Not Available"; } ?>
													</div>
														<div class="col-md-8" style="margin-top:2%;">
															<span><b>Product Name:</b> <?php echo $products['product_name'];?></span><br>
															<span><b>Product Description:</b> <?php echo $products['product_description'];?></span><br>
															<span><b>Product Price:</b> <?php echo "$".$products['product_price'];?></span><br>
															<span><b>Product Quantity:</b> <?php echo $products['qty'];?></span><br>
														<?php
														if(!empty($products['addons'])) {
															?>
															<span><b>Product Addons:</b></span>
															<?php
															$i = 0;
															foreach($products['addons'] as $addons) { $i++;
															?>
															<span><?php echo $i."). ".$addons['addon_name'];?> - <?php echo "$".$addons['addon_price'];?></span><br>
															<?php
															}
														}
														?>
														</div>
													</div>
														<?php
													}
												}
											?>
										
										</div>
									</div>
								</div>
									
									<?php
									}
								}
							?>
						</div>
					</div>
				</div>
			</div>
			<?php } ?>
			<?php 
			if(!empty($is_manual_store) && !empty($driver)){
			?>
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Driver Payment Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
							<div class="col-md-12">
							<?php 
									if(!empty($is_manual_store)){
										if(!empty($manual_store)){
											foreach($manual_store as $manual){
												$store_amount[] = $manual->store_amount;
											}
											$total_store = array_sum($store_amount);
											$shopping_fee_val = ($shopping_fee*$values['shopping_fee_percentage'])/100;
											$all_val = $total_store;
											?>
											<!-- <span><b>Manual Store Amount :</b><?php echo "$".$total_store;?></span>&nbsp;&nbsp;
											<span><b>Shopping Fee :</b><?php echo "$".$shopping_fee_val;?></span>&nbsp;&nbsp;
											<span><b>Tip :</b><?php echo "$".$order['tip'];?></span><br><br> -->
											<span><b class="ti_cl">Total Payable Amount to Driver :</b><span style="margin-left: 3%;"><?php echo "$".$all_val;?></span></span><br>
											<span class="pay_class"><b class="ti_cl">Actual Amount Pay to Driver :</b>
											<input type="text" name="amount_driver" class="form-control" placeholder="Ex:200" value="<?php if(!empty($driver_payment_data)){echo $driver_payment_data[0]['actual_amount_to_pay'];}else { echo $all_val;}?>"></span><br>
											<span class="pay_class"><b class="ti_cl">Add comment for Driver Payment :</b>
											<input type="text" name="driver_comment" class="form-control" placeholder="Comment" value="<?php if(!empty($driver_payment_data)){echo $driver_payment_data[0]['comment'];} ?>"></span><br>
											<span class="pay_class"><b class="ti_cl conf_chk">Confirm Driver Payment:</b>
											<input type="checkbox" name="driver_pay_confirm" id="driver_pay_confirm" class="styled " <?php if(!empty($driver_payment_data)){if($driver_payment_data[0]['confirm_payment'] == 1){echo "checked";}}?>>
											<input type="hidden" name=dr_order_id value="<?php echo $order['order_id'];?>">
											<input type="hidden" name=dr_driver_id value="<?php echo $driver['user_id'];?>">
											<input type="hidden" name="total_shopping_fee" value="<?php echo ($shopping_fee*$values['shopping_fee_percentage'])/100;?>">
											<!-- <input type="hidden" name="start_date" value=<?php echo date('Y-m-d', strtotime($order['created_at']));?>> -->
											<?php
											if(!empty($driver_payment_data)){
											?><input type="hidden" name="dr_id" value="<?php echo $driver_payment_data[0]['weekly_payment_id'];?>"><?php
											}
											?>
											<?php
										}
									}
								?>
							</div>
						</div>
					</div>
				</div>
			</div>
			<?php }?>
			<!-- <div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Admin Payment Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
							<div class="col-md-12">
								<span><b class="ti_cl">Total Order Amount :</b><span style="margin-left: 9%;"><?php echo "$".$total_order;?></span></span><br>
								<span class="pay_class"><b class="ti_cl">Total Amount pay to Driver from System :</b>
								<input type="text" name="amount_driver_system" class="form-control" placeholder="Ex:200"></span><br>
                                <span class="pay_class"><b class="ti_cl">Total Amount pay to Restaurant from System :</b><input type="text" name="amount_res_system" class="form-control" placeholder="Ex:200"></span><br>
								<span class="pay_class"><b class="ti_cl">Add Comment :</b><input type="text" name="comment" placeholder="Comment" class="form-control"></span><br>
								<span><b class="ti_cl" style="margin-right: 5%;">Confirm Payment to Driver : </b><input type="checkbox" name="con_dri" class="styled"></span><br>
								<span><b class="ti_cl" style="margin-right: 2.3%;">Confirm Payment to Restaurant : </b><input type="checkbox" name="con_res" class="styled"></span><br>
                            </div>
						</div>
					</div>

				</div>
			</div> -->
				<?php //}?>
		</div>	
		<div class="btn-bottom-toolbar text-right btn-toolbar-container-out">
			<?php //if(!empty($driver)) { ?>
			<button type="submit" class="btn btn-success save_changes" name="submit"><?php _el('save'); ?></button><?php //}?>
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
.conf_chk{
	width:20% !important;
}
</style>
<script type="text/javascript" src="../../../../Socket/node_modules/socket.io-client/dist/socket.io.js"></script>
<script>
$(document).ready(function(){
	$(document).on('click','.save_changes',function(){
		if($("#driver_pay_confirm").is(":checked")){
			var driver_id = '<?php echo $driver["user_id"];?>';
			var order_id = '<?php echo $order['order_id'];?>';
			var socket = io.connect('http://34.204.81.189:30080/'); 
			var data = {
				order_id : order_id,
				driver_id : driver_id
			};
			socket.emit('confirm_manual_store_payment', data, function(callBack) {
				console.log(callBack);
			}) ; 
		}
	});
});


// $("#orderform").validate({
//     rules: {
//         amount_driver_system: {
//             required: true,
// 			number:true
//         },
//         amount_res_system: {
//             required: true,
// 			number:true
//         },
//     },
//     messages: {
//         amount_driver_system: {
//             required:"Total Amount pay to Driver from System is required",
// 			number:"Please enter valid Amount"
//         },
//         amount_res_system: {
//             required:"Total Amount pay to Store from System is required",
// 			number:"Please enter valid Amount"
//         },
//     },
// }); 

</script>
