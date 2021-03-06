<!-- Page header -->
<div class="page-header page-header-default">
    <div class="page-header-content">
        <div class="page-title">
            <h4>
                <span class="text-semibold"><?php _el('service_category'); ?></span>
            </h4>
        </div>
    </div>
    <div class="breadcrumb-line">
        <ul class="breadcrumb">
            <li>
                <a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
            </li>
            <li class="active"><?php _el('service_category'); ?></li>
        </ul>
    </div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
    <!-- Panel -->
    <div class="panel panel-flat">
        
        <!-- Panel heading -->
        <div class="panel-heading">
                <a href="<?php echo base_url('admin/servicecategory/add'); ?>" class="btn btn-primary"><?php _el('add_new'); ?><i class="icon-plus-circle2 position-right"></i></a>  
                <a href="javascript:delete_selected();" class="btn btn-danger" id="delete_selected"><?php _el('delete_selected'); ?><i class=" icon-trash position-right"></i></a>
        </div>
        <!-- /Panel heading -->
        
       
        <!-- Listing table -->
        <div class="panel-body table-responsive">
            <table id="categories_table" class="table  table-bordered table-striped">
                <thead>
                    <tr>
                        
                        <th width="2%">
                            <input type="checkbox" name="select_all" id="select_all" class="styled"  onclick="select_all(this);" >
                        </th>
                        <th width="20%"><?php _el('cat_image'); ?></th>
                        <th width="20%"><?php _el('category_name'); ?></th>
                        <th width="20%"><?php _el('service_category_description'); ?></th>
                        <th width="8%" class="text-center"><?php _el('status'); ?></th>
                        
                        <th width="8%" class="text-center"><?php _el('actions') ?></th>
                        
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($categories as $key => $category) { ?>
                    <tr>
                        
                        <td>
                            <input type="checkbox" class="checkbox styled"  name="delete"  id="<?php echo $category['service_category_id']; ?>">
                        </td>
                        <td><img src="<?php echo DISPLAY_SERVICE_CATEGORIES.$category['service_category_image'];?>" alt="<?php echo $category['service_category_name'];?>" style="width: 80px;height:60px;" onError="this.onerror=null;this.src='<?=base_url() . 'assets/admin/images/no_image.png'?>';"></td>
                        <td><?php echo ucfirst($category['service_category_name']); ?></td>
                        <td><?php echo ucfirst($category['service_category_description']);?></td>
                        <td class="text-center switchery-sm">
                            <input type="checkbox" onchange="change_status(this);" class="switchery"  id="<?php echo $category['service_category_id']; ?>" <?php if ($category['is_active']==1) { echo "checked"; }  ?>>
                        </td>
                        
                        <td class="text-center">
                            <a data-popup="tooltip" data-placement="top"  title="<?php _el('view') ?>" href="<?php echo site_url('admin/servicecategory/view/').$category['service_category_id']; ?>" id="<?php echo $category['service_category_id']; ?>" class="text-info">
                                <i class="icon-eye"></i>
                            </a>
                            <a data-popup="tooltip" data-placement="top"  title="<?php _el('edit') ?>" href="<?php echo site_url('admin/servicecategory/edit/').$category['service_category_id']; ?>" id="<?php echo $category['service_category_id']; ?>" class="text-info">
                                <i class="icon-pencil7"></i>
                            </a>
                        
                        
                            <a data-popup="tooltip" data-placement="top"  title="<?php _el('delete') ?>" href="javascript:delete_record(<?php echo $category['service_category_id']; ?>);" class="text-danger delete" id="<?php echo $category['service_category_id']; ?>">
                                <i class=" icon-trash"></i>
                            </a>
                        
                        </td>
                        
                    </tr>
                    <?php } ?>
                </tbody>
            </table>           
        </div>
        <!-- /Listing table -->
    </div>
    <!-- /Panel -->
</div>
<!-- /Content area -->

<!-- Add form modal -->
<div id="add_category_modal" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-primary">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h5 class="modal-title"><?php _el('add_category'); ?></h5>
            </div>

            <form action="<?php echo base_url('admin/categories/add'); ?>" id="categoryform" method="POST">
                <div class="modal-body">
                    <div class="form-group">
                        <div class="row">
                            <div class="col-sm-12">
                                <small class="req text-danger">*</small>
                                <label><?php _el('name'); ?>:</label>
                                <input type="text" class="form-control" placeholder="<?php _el('category_name'); ?>" id="name" name="name"> 
                            </div>                           
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal"><?php _el('close'); ?></button>
                    <button type="submit" class="btn btn-primary"><?php _el('save'); ?></button>
                </div>
            </form>
        </div>
    </div>
</div>
<!-- /Add form modal -->



<script type="text/javascript">
$(function() {

    $('#categories_table').DataTable({        
        'columnDefs': [ {
        'targets': [0,2,3], /* column index */
        'orderable': false, /* disable sorting */
        }],
         
    });

    //add class to style style datatable select box
    $('div.dataTables_length select').addClass('datatable-select');
 });

$("#categoryform").validate({   
    rules: {
        name:
        {
            required: true,
        },
    },
    messages: {
        name: {
            required:"<?php _el('please_enter_', _l('category_name')) ?>",
        },        
    }
});  


var BASE_URL = "<?php echo base_url(); ?>";

/**
 * Change status when clicked on the status switch
 *
 * @param {obj}  obj  The object
 */
function change_status(obj)
{
    var checked = 0;     

    if(obj.checked) 
    { 
        checked = 1;
    }  

    $.ajax({
        url:BASE_URL+'admin/servicecategory/update_status',
        type: 'POST',
        data: {
            category_id: obj.id,
            is_active:checked
        },
        success: function(msg) 
        {
            if (msg=='true')
            {                           
                jGrowlAlert("<?php _el('_activated', _l('service_category')); ?>", 'success');
            }
            else
            {                  
                jGrowlAlert("<?php _el('_deactivated', _l('service_category')); ?>", 'success');
            }
        }
    }); 
}

/**
 * Deletes a single record when clicked on delete icon
 *
 * @param {int}  id  The identifier
 */
function delete_record(id) 
{ 
    swal({
        title: "<?php _el('single_deletion_alert'); ?>",
        text: "<?php _el('single_recovery_alert'); ?>",
        type: "warning",  
        showCancelButton: true, 
        cancelButtonText:"<?php _el('no_cancel_it'); ?>",
        confirmButtonText: "<?php _el('yes_i_am_sure'); ?>",      
    },
    function()
    {       
        $.ajax({
            url:BASE_URL+'admin/servicecategory/delete',
            type: 'POST',
            data: {
                category_id:id
            },
            success: function(msg)
            {
                if (msg=="true")
                {                    
                    swal({                        
                        title: "<?php _el('_deleted_successfully', _l('category')); ?>",       
                        type: "success",                            
                    });
                    $("#"+id).closest("tr").remove();
                }
                else
                {                        
                    swal({                           
                        title: "<?php _el('access_denied', _l('category')); ?>",
                        type: "error",                               
                    });
                }  
            }
        });
    });
}

/**
 * Deletes all the selected records when clicked on DELETE SELECTED button
 */
function delete_selected() 
{     
    var category_ids = [];

    $(".checkbox:checked").each(function()
    {
        var id = $(this).attr('id');
        category_ids.push(id);
    });
    if (category_ids == '')
    {
        jGrowlAlert("<?php _el('select_before_delete_alert') ?>", 'danger');
        preventDefault();
    }
    swal({
        title: "<?php _el('multiple_deletion_alert'); ?>",
        text: "<?php _el('multiple_recovery_alert'); ?>",
        type: "warning",
        showCancelButton: true, 
        cancelButtonText:"<?php _el('no_cancel_it'); ?>",
        confirmButtonText: "<?php _el('yes_i_am_sure'); ?>", 
    },
    function()
    {
        $.ajax({
            url:BASE_URL+'admin/servicecategory/delete_selected',
            type: 'POST',
            data: {
              ids:category_ids
            },
            success: function(msg)
            {
                if (msg=="true")
                {                     
                  swal({                           
                        title: "<?php _el('_deleted_successfully', _l('categories')); ?>",                    
                        type: "success",                            
                    });
                  $(category_ids).each(function(index, element) 
                  {
                      $("#"+element).closest("tr").remove();
                  });
                }
                else
                {
                  swal({                            
                       title: "<?php _el('access_denied', _l('category')); ?>",
                        type: "error",   
                    });
                }
            }
        });
    });
}

</script>
