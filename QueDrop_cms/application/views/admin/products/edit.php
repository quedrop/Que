<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold"><?php _el('edit_product'); ?></span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>	
			</li>
			<li>
				<a href="<?php echo base_url('admin/products'); ?>"><?php _el('products'); ?></a>
			</li>
			<li class="active"><?php _el('edit'); ?></li>
		</ul>
	</div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
	<form action="<?php echo base_url('admin/products/edit/').$product['product_id']; ?>" id="productform" method="POST" enctype="multipart/form-data">
		<div class="row">
			<div class="col-md-8 col-md-offset-2">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong><?php _el('product'); ?></strong>
								</h5>
							</div>
						</div>
					</div>
					<!-- /Panel heading -->
					<!-- Panel body -->
					<div class="panel-body">
						<div class="row">
							<div class="col-md-12">
								<div class="form-group">
									<small class="req text-danger">*</small>
									<label><?php _el('product_name'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('product_name'); ?>" id="name" name="name" value="<?php echo $product['product_name']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">*</small>
									<label><?php _el('description'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('description'); ?>" id="description" name="description" value="<?php echo $product['product_description'];?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">*</small>
									<label>Store:</label>
									<select name="store" id="store" class="select" onchange="get_category(this.value);">
										<option value="">Select Store</option>
										<?php 
										if(!empty($store)) {
											foreach($store as $cat) {
											?>
											<option value="<?php echo $cat['store_id'];?>" <?php if($cat['store_id'] == $store_id) {echo "selected=selected";}?>><?php echo $cat['store_name'];?></option>
											<?php
											}
										}
										?>
									</select>
								</div>
								<div class="form-group">
									<small class="req text-danger">*</small>
									<label><?php _el('category'); ?>:</label>
									<select name="category" id="category" class="select">
										<option value="">Select Category</option>
										<?php 
											if(!empty($store_category))	{ 
												foreach($store_category as $store_cat) {
												?>
												<option value="<?php echo $store_cat['store_category_id']?>"  <?php if($store_cat['store_category_id'] == $product['store_category_id']){echo "selected";}?>><?php echo $store_cat['store_category_title'];?></option>
												<?php
												}
											}
										?>
									</select>
								</div>
								<div class="form-group">
									<small class="req text-danger"></small>
									<label><?php _el('product_image'); ?>:</label>
									<input type="file" class="form-control" name="product_image" id="product_image" accept=".png, .jpg, .jpeg">
									<input type="hidden" name="old_image" id="old_image" value="<?php echo $product['product_image'];?>">
								</div>
								<!-- <div class="form-group">
									<small class="req text-danger">*</small>
									<label><?php _el('price'); ?>:</label>
									
								</div> -->
								<input type="hidden" class="form-control" placeholder="<?php _el('price'); ?>" id="price" name="price" value="<?php echo $product['product_price'];?>">
								<div class="form-group">
									<label><?php _el('extra_fees'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('extra_fees'); ?>" id="extra_fees" name="extra_fees" value="<?php echo $product['extra_fees'];?>">
								</div>
								
								<?php if(!empty($options)) {
									$count = count($options);
								} else {
									$count = 1;
								}?>
								
								<div class="form-group">
									<label>Product Options:</label>
									<a id="add-btn" class="btn btn-primary" onclick="add_option(<?php echo $count;?>);">Add Option<i class="icon-plus-circle2 position-right"></i></a>
									<input type="hidden" name="delete_option" id="delete_option">
								</div>
								<div class="option_div">
									<table id="option">
										<tr>
											<th>Product Option</th>
											<th>Price</th>
											<th>Is default</th>
											<th></th>
										</tr>
										<tbody id="op_body">
											<?php
												if(!empty($options)){ $i=0;
													foreach($options as $op){
														$i++;
													?>
														<tr id="<?php echo $i;?>">
															<td>
																<input type="hidden" name="id[]" value="<?php echo $op['option_id'];?>" id="op_id_<?php echo $i;?>">  
																<input type="text" name="option[]" placeholder="Ex. Small,Medium,Large,1 kg,500 gm" class="form-control" value="<?php echo $op['option_name'];?>">
															</td>
															<td>
																<input type="text" name="option_price[]" placeholder="100" class="form-control" value="<?php echo $op['price']?>">
															</td>
															<td>
																<input type="radio" class="form-control rd_st" name="rd_chk"  id="rd_st_<?php echo $i;?>" onchange="check_val(<?php echo $i;?>);" <?php if($op['is_default'] == 1){echo "checked";}?>>
																<input type="hidden" name="is_default[]" id="def_<?php echo $i;?>" value="<?php echo $op['is_default'];?>" class="chk_de">
															</td>
															<td><a data-popup="tooltip" data-placement="top" href="javascript:delete_option(<?php echo $i;?>);" class="text-danger delete"><i class=" icon-trash"></i></a></td>
														</tr>
													<?php
													}
												} else {
												?>
												<tr id="1">
													<td>
														<input type="text" name="option[]" placeholder="Ex. Small,Medium,Large,1 kg,500 gm" class="form-control">
													</td>
													<td>
														<input type="text" name="option_price[]" placeholder="100" class="form-control">
													</td>
													<td>
														<input type="checkbox" class="checkbox styled">
														<input type="hidden" name="is_default[]" id="def_1" value="0">
													</td>
												</tr>
												<?php
												}
											?>
										</tbody>
										
									</table>
								</div>

								<div class="form-group">
									<label>Product Addons:</label>
									<?php if(!empty($addons)) {
										$count = count($addons);
									} else {
										$count = 1;
									}?>
									<a id="addon-btn" class="btn btn-primary" onclick="add_addons(<?php echo $count;?>);">Add Addons<i class="icon-plus-circle2 position-right"></i></a>
									<input type="hidden" name="delete_addon" id="delete_addon">
								</div>
								<div class="option_div">
									<table id="option">
										<tr>
											<th>Addon Name</th>
											<th>Price</th>
											<th></th>
										</tr>
										<tbody id="ad_body">
											<?php 
											if(!empty($addons)){ $j=0;
												foreach($addons as $adon){
													$j++;
												?>
												<tr id="add_<?php echo $j;?>">
													<td>
														<input type="hidden" name="addon_id[]" id="addon_<?php echo $j;?>" value="<?php echo $adon['addon_id'];?>">
														<input type="text" name="addob_name[]" placeholder="Ex. Extra Cheese,Red Peprika,Cheese Dip" class="form-control" value="<?php echo $adon['addon_name'];?>">
													</td>
													<td>
														<input type="text" name="addon_price[]" placeholder="100" class="form-control" value="<?php echo $adon['addon_price'];?>">
													</td>
													<td><a data-popup="tooltip" data-placement="top" href="javascript:delete_addons(<?php echo $j;?>);" class="text-danger delete"><i class=" icon-trash"></i></a></td>
												</tr>
												<?php
												}
											} else {
											?>
											<tr id="add_1">
												<td>
													<input type="text" name="addob_name[]" placeholder="Ex. Extra Cheese,Red Peprika,Cheese Dip" class="form-control">
												</td>
												<td>
													<input type="text" name="addon_price[]" placeholder="100" class="form-control">
												</td>
											</tr>
											<?php
											}
											?>
										</tbody>
									</table>
								</div>

								<div class="form-group">
									<label><?php _el('status'); ?>:</label>
									<input type="checkbox" class="switchery" name="is_active" id="<?php echo $product['product_id']; ?>" <?php if($product['is_active']==1) { echo "checked";} ?> >
								</div>

								<div class="form-group">
									<label>Product Verified : </label>&nbsp;&nbsp;
									<input type="checkbox" class="styled" name="is_verified" id="<?php echo $product['is_verified']; ?>" <?php if($product['is_verified']==1) { echo "checked";} ?>>
								</div>
							</div>
						</div>
					</div>
					<!-- /Panel body -->
				</div>
				<!-- /Panel -->
			</div>
		</div>
		<div class="btn-bottom-toolbar text-right btn-toolbar-container-out">
		<button type="submit" class="btn btn-success" name="submit"><?php _el('save'); ?></button>
		<a class="btn btn-default" onclick="window.history.back();"><?php _el('back'); ?></a>
		</div>
	</form>
</div>
<!-- /Content area -->
<style>
#option {
  font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

#option td, #option th {
  padding: 8px;
}

.rd_st{
	width: 25%;
    margin-left: 30% !important;
	cursor:pointer;
}
</style>
<script type="text/javascript">
function add_addons(id){
	var new_id = parseInt(id+1);
	var html = '<tr id="add_'+new_id+'"><td><input type="text" name="addob_name[]" placeholder="Ex. Extra Cheese,Red Peprika,Cheese Dip" class="form-control"></td><td><input type="text" name="addon_price[]" placeholder="100" class="form-control"></td><td><a data-popup="tooltip" data-placement="top" href="javascript:delete_addons('+new_id+');" class="text-danger delete"><i class=" icon-trash"></i></a></td></tr>';
	// $("#add_"+id).after(html);
	$("#ad_body").append(html);
	$("#addon-btn").attr("onclick","add_addons("+new_id+")");
}

function delete_addons(id){
	var delete_op = $("#delete_addon").val();
	var ad_id = $("#addon_"+id).val(); 
	if(delete_op == ''){
		$("#delete_addon").val(ad_id);
	} else {
		$("#delete_addon").val(delete_op+","+ad_id);
	}
	$("#add_"+id).remove();
}

function add_option(id)
{
	var new_id = parseInt(id+1);
	var html = '<tr id="'+new_id+'"><td><input type="text" name="option[]" placeholder="Ex. Small,Medium,Large,1 kg,500 gm" class="form-control"></td><td><input type="text" name="option_price[]" placeholder="100" class="form-control"></td><td><div class="rd_checked"><span id="check_'+new_id+'" ><input type="radio" class="form-control rd_st" name="rd_chk" id="rd_st_'+new_id+'" onchange="check_val('+new_id+');"><input type="hidden" name="is_default[]" id="def_'+new_id+'" value="0" class="chk_de"></span></div></td><td><a data-popup="tooltip" data-placement="top" href="javascript:delete_option('+new_id+');" class="text-danger delete"><i class=" icon-trash"></i></a></td></tr>';
	// $("#"+id).after(html);
	$("#op_body").append(html);
	$("#add-btn").attr("onclick","add_option("+new_id+")");
}

function check_val(id){
	$(".chk_de").val(0);
	if($("#rd_st_"+id).is(':checked')){
		$("#def_"+id).val(1);
	} else {
		$("#def_"+id).val(0);
	}
}

function delete_option(id){
	var delete_op = $("#delete_option").val();
	var ad_id = $("#op_id_"+id).val(); 
	if(delete_op == ''){
		$("#delete_option").val(ad_id);
	} else {
		$("#delete_option").val(delete_op+","+ad_id);
	}
	$("#"+id).remove();
}


$.validator.addMethod('filesize', function (value, element, param) {
    return this.optional(element) || (element.files[0].size <= param)
}, 'File size must be less than {0}');
$("#productform").validate({
	rules: {
		name:
		{
			required: true,
		},
		description:{
			required:true,
		},
		store:{
			required:true,
		},
		category:{
			required:true,
		},
		// price:{
		// 	required:true,
		// 	number:true,
		// },
		product_image:{
			filesize: 2097152,
		},
		extra_fees:{
			number:true,
		},
		'option_price[]':{
			number:true,
		},
		'addon_price[]':{
			number:true,
		},
	},
	messages: {
		name: 
		{
			required:"<?php _el('please_enter_', _l('product_name')) ?>",
		},
		description:
		{
			required:"<?php _el('please_enter_', _l('description')) ?>",
		},
		store:{
			required:"Please select Store",
		},
		category:{
			required:"<?php _el('please_enter_', _l('category')) ?>",
		},
		// price:{
		// 	required:"<?php _el('please_enter_', _l('price')) ?>",
		// 	number:"Please Enter Valid Price",
		// },
		product_image:{
			filesize:"file size must be less than 2 MB.",
		},
		extra_fees:{
			number:"Please Enter Valid Extra Fees",
		},
		'option_price[]':{
			number:"Please Enter Valid Price",
		},
		'addon_price[]':{
			number:"Please Enter Valid Price",
		}
		
	}
}); 

var BASE_URL = "<?php echo base_url(); ?>";

function get_category(id) {
	$("#category").find('option')
    .remove();
	$("#category :selected").remove();
	$.ajax({
        url:BASE_URL+'admin/products/get_category',
        type: 'POST',
        data: { id: id },
        async: false,
        success: function(data) 
        {   
            if(data != ''){
				$("#category").append(data);
			}
        }
    });
}
</script>

